//
//  LensFlareView.swift
//  Running with a Snap
//
//  Created by Seyed Samad Gholamzadeh on 7/11/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

func randomFloat(_ min: CGFloat, _ max: CGFloat) -> CGFloat {
//	let random = CGFloat(arc4random_uniform(UInt32(max - min))) + min
	let random = (CGFloat(arc4random()) / 0x100000000) * (max - min) + min
	return random
}

class LensFlareView: UIView {

	override convenience init(frame: CGRect) {
		self.init(frame: frame, flareLineEndPoint: CGPoint(x: 200, y: frame.height))
	}
	
	init(frame: CGRect, flareLineEndPoint endPoint: CGPoint) {
		super.init(frame: frame)
		self.addFlareToEndPoint(endPoint)
		self.alpha = randomFloat(0.15, 0.25)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// Assumes a right-to-left downward slope starting at {0,0}
	func addFlareToEndPoint(_ endPoint: CGPoint) {
		
		let hypotenuse: CGFloat = sqrt(pow(endPoint.x,2) + pow(endPoint.y,2))
		let degrees: CGFloat = atan(tan(endPoint.x / endPoint.y)) * 100
		let radians: CGFloat = (90.0 - degrees) * CGFloat.pi / 180.0
		
		var pointOnHypontenuse: CGFloat = randomFloat(20, 30)
		var flareSize: CGFloat = 0.0
		
		repeat {
			
			let p: CGPoint = CGPoint(x: pointOnHypontenuse * cos(radians), y: pointOnHypontenuse * sin(radians))
			
			// Create a lens flare
			flareSize = randomFloat(20, 225)
			let blob = LensFlareBlob(frame: CGRect(x: 0, y: 0, width: flareSize, height: flareSize), points: 7, startAngle: randomFloat(0, CGFloat.pi))
			blob?.center = p
			
			// Pick a random color and assign it to a new color motion effect
			let randomColor = UIColor(hue: randomFloat(0, 1), saturation: 1.0, brightness: randomFloat(0.2, 0.6), alpha: 1.0)
			let colorMotion = LensFlareColorMotionEffect(color: randomColor)
			
			// Create a new diagonal motion effect
			let diagonalEffect = LensFlareDiagonalMotionEffect()
			diagonalEffect.minValue = -20
			diagonalEffect.maxValue = 30

			// Group the motion effects together so they get evaluated simultaneously
			let group = UIMotionEffectGroup()
			group.motionEffects = [colorMotion, diagonalEffect]
			blob?.addMotionEffect(group)
			
			self.addSubview(blob!)
			
			pointOnHypontenuse += randomFloat(flareSize * 0.7, flareSize * 0.7 + 80)
		}
		while pointOnHypontenuse < hypotenuse
	}

}

class LensFlareBlob: UIView {
	
	class override var layerClass: AnyClass {
		return CAShapeLayer.self
	}
	
	init?(frame: CGRect, points numberOfPoints: Int, startAngle angle: CGFloat) {
		if numberOfPoints < 3 {
		print("points must be 3 or greater")
			return nil
		}
		
		// Make us square
		var frame = frame
		var angle = angle

		frame.size.height = frame.size.width
		
		super.init(frame: frame)
		
		self.clipsToBounds = true
		var pointsDrawn: Int = 0
		let path = UIBezierPath()
		let radius = self.bounds.width/2.0
		var p = CGPoint(x: radius * cos(angle) + radius, y: radius * sin(angle) + radius)
		path.move(to: p)
		
		repeat {
			pointsDrawn += 1
			angle += (CGFloat.pi * 2) / CGFloat(numberOfPoints)
			p = CGPoint(x: radius * cos(angle) + radius, y: radius * sin(angle) + radius)
			path.addLine(to: p)
			
		} while pointsDrawn < numberOfPoints
		
		path.close()
		
		let sl = (self.layer as! CAShapeLayer)
		sl.path = path.cgPath
		
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

class LensFlareDiagonalMotionEffect: UIMotionEffect {
	
	var minValue: CGFloat!
	var maxValue: CGFloat!
	
	override func keyPathsAndRelativeValues(forViewerOffset viewerOffset: UIOffset) -> [String : Any]? {
		// Math!
		let f: CGFloat = (viewerOffset.horizontal / 2.0) + 0.5
		let calculatedValue: CGFloat = self.minValue * (1 - f) + self.maxValue * f
		let rotationTransform = CGAffineTransform(rotationAngle: CGFloat.pi/4)
		let rotatedPoint = CGPoint(x: calculatedValue, y: 0).applying(rotationTransform)
		
		return ["center.x" : rotatedPoint.x, "center.y" : rotatedPoint.y]
	}
}

class LensFlareColorMotionEffect: UIMotionEffect {
	
	var hue: CGFloat!
	var brightness: CGFloat!
	var color: UIColor
	
	init(color: UIColor) {
		self.color = color
		super.init()
		
		var h: CGFloat = 0
		var b: CGFloat = 0
		self.color.getHue(&h, saturation: nil, brightness: &b, alpha: nil)
		
		self.hue = h
		self.brightness = b
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func keyPathsAndRelativeValues(forViewerOffset viewerOffset: UIOffset) -> [String : Any]? {
		// Map horizontal movement to brightness and vertical movement to hue.
		var hue: CGFloat = 0.0
		var brightness: CGFloat = 0.0
		
		// Math!
		if viewerOffset.horizontal > 0 {
			brightness = self.brightness + (1 - self.brightness) * viewerOffset.horizontal
		}
		else {
			brightness = self.brightness + self.brightness * viewerOffset.horizontal
		}
		var floatValue: Float = 0.0
		hue = CGFloat(fabs(modff(Float(1.0 + self.hue + viewerOffset.vertical), &floatValue)))
		let newColor = UIColor(hue: hue, saturation: 1.0, brightness: brightness, alpha: 1.0)
		
		return ["layer.fillColor" : newColor.cgColor]
	}
}



