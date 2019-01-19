//
//  RootView.swift
//  Animation101
//
//  Created by Seyed Samad Gholamzadeh on 3/7/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

func midPoint(_ r: CGRect) -> CGPoint {
	return CGPoint(x: r.midX, y: r.midY)
}

// Positive random number in this range
func randomNumber(_ min: CGFloat, _ max: CGFloat)-> CGFloat {
	return CGFloat(arc4random_uniform(UInt32(max-min)) + UInt32(min));
}

func CATransform3DMakePerspective(_ z: CGFloat) -> CATransform3D {
	
	var t = CATransform3DIdentity
	t.m34 = -1 / z
	return t
}


class RootView: UIView {

	var spadeAce: CALayer!
	var viewState: Int
	var jumping: JumpingText!
	var ball: CAShapeLayer!
	var ballDelegate: BallDelegate!
	

	override init(frame: CGRect) {
		
		// for demo purposes, use viewState
		viewState = 0;
		
		super.init(frame: frame)

		// Add perspective for the rotation
		
		self.layer.sublayerTransform = CATransform3DMakePerspective(-900)
		self.backgroundColor = .white
		// Now add the sub layers
		
		// Add the card layer
		spadeAce = CALayer()
		
		// The properties of the card:
		spadeAce.bounds = CGRect(x: 0, y: 0, width: 190, height: 280);
		// Center it in the view
		spadeAce.position = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
		let space = CGColorSpaceCreateDeviceRGB()
		let componenets: [CGFloat] = [0.4, 0.8, 1, 0.6]
		let cardBackColor = CGColor(colorSpace: space, components: componenets)
		spadeAce.backgroundColor = cardBackColor
		spadeAce.isOpaque = false
		// The card has a dark gray border with rounded corners
		spadeAce.borderWidth = 5
		spadeAce.borderColor = UIColor.darkGray.cgColor
		spadeAce.cornerRadius = 5.0
		
		self.layer.addSublayer(spadeAce)
		
		// Add the pips
		let centerPip: CAShapeLayer = Cards.spadePip
		centerPip.position = midPoint(spadeAce.bounds)
		spadeAce.addSublayer(centerPip)

		let componenets1: [CGFloat] = [0.1, 0.1, 0.1, 0.98]

		let almostBlack = CGColor(colorSpace: space, components: componenets1)
		// Top pip
		var A = CATextLayer()
		A.string = "A"
		A.bounds = CGRect(origin: .zero, size: CGSize(width: 30, height: 24))
		A.foregroundColor = almostBlack
		A.position = CGPoint(x: 26, y: 20)
		A.fontSize = 26
		spadeAce.addSublayer(A)
	
		let indexTop = Cards.spadePip
		indexTop.position = CGPoint(x: 20, y: 44)
		indexTop.transform = CATransform3DMakeScale(0.5, 0.5, 1)
		spadeAce.addSublayer(indexTop)
		
		// Bottom pip
		A = CATextLayer()
		A.string = "A"
		A.bounds = CGRect(origin: .zero, size: CGSize(width: 30, height: 24))
		A.foregroundColor = almostBlack
		A.position = CGPoint(x: spadeAce.bounds.maxX - 26, y: spadeAce.bounds.maxY - 20)
		A.transform = CATransform3DMakeRotation(CGFloat.pi, 0, 0, 1)
		A.fontSize = 26
		spadeAce.addSublayer(A)
		
		var transform = CATransform3DMakeScale(0.5, 0.5, 1)
		transform = CATransform3DRotate(transform, CGFloat.pi, 0, 0, 1)
		
		let indexBottom = Cards.spadePip
		indexBottom.position = CGPoint(x: spadeAce.bounds.maxX - 20, y: spadeAce.bounds.maxY - 44)
		indexBottom.transform = transform
		spadeAce.addSublayer(indexBottom)
		
		// Create a ball, position it offscreen
		ball = CAShapeLayer()
		ball.bounds = CGRect(origin: .zero, size: CGSize(width: 60, height: 60))
		ball.position = CGPoint(x: self.bounds.midX, y: -60)
		
		ballDelegate = BallDelegate()
		ballDelegate.parent = self
		ball.delegate = ballDelegate
		
		ball.setNeedsDisplay()
		self.layer.addSublayer(ball)
		
		// Jumping text:
		jumping = JumpingText()
		
		// Recognize a tap gesture to cycle through the animations
		let recognizerTap = UITapGestureRecognizer(target: self, action: #selector(tapRecognized(_:)))
		self.addGestureRecognizer(recognizerTap)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func scatterLetters() {
		
		// This animation sends the letters scattering in random directions,
		// and then fading away.
		// An animation group is added to each letter layer.
		// The group is up of two basic animations: one to move and one to fade.
		// We use the CAMediaTiming protocol to delay the fade by 2 seconds.
		
		let animationTime: CGFloat = 5
		// Delayed fade
		let fade = CABasicAnimation(keyPath: "opacity")
		fade.fromValue = NSNumber(value: 1)
		fade.toValue = NSNumber(value: 0)
		fade.duration = CFTimeInterval(animationTime - 2)
		fade.beginTime = 2
		for letter in jumping.letters {
			let x = randomNumber(0, self.bounds.maxX)
			let y = randomNumber(0, self.bounds.maxY)
			let move = CABasicAnimation(keyPath: "position")
			move.toValue = NSValue(cgPoint: CGPoint(x: x, y: y))
			move.duration = CFTimeInterval(animationTime)
			let moveAndVanish = CAAnimationGroup()
			moveAndVanish.animations = [fade, move]
			moveAndVanish.duration = CFTimeInterval(animationTime)
			moveAndVanish.isRemovedOnCompletion = false
			moveAndVanish.fillMode = kCAFillModeForwards
			letter.add(moveAndVanish, forKey: nil)
		}
	}

	@objc func tapRecognized( _ gestureRecognizer: UIGestureRecognizer) {
		// The first time a click occurs, rotate the card.
		if viewState == 0 {
			CATransaction.setAnimationDuration(3)
			spadeAce.transform = CATransform3DMakeRotation(1.2, -1, -1, 0)
			viewState += 1
		}
		else if viewState == 1 {
			// An implicit animation to send the card back
			CATransaction.setAnimationDuration(1)
			spadeAce.transform = CATransform3DIdentity;
			viewState += 1
		}
		else if viewState == 2 {
			// Add some CATextLayers
			spadeAce.opacity = 0
			jumping.addTextLayers(to: self.layer)
			viewState += 1
		}
		else if viewState == 3 {
			// Lets go bowling!
			let move = CABasicAnimation(keyPath: "position.y")
			move.duration = 2
			
			// Take the radius of the ball into account when computing the strike point
			move.toValue = NSNumber(value: Float(jumping.topOfString - ball.bounds.height/2))
			move.delegate = ballDelegate
			ball.add(move, forKey: nil)
			viewState += 1
		}
		else if viewState == 4 {
			jumping.removeTextLayers()
			// A bouncing ball that uses linear timing.
			// KeyFrame animation
			ball.position = CGPoint(x: 20, y: 20)
			let bounce = CAKeyframeAnimation(keyPath: "position")
			bounce.duration = 4
			let path = CGMutablePath()
			path.move(to: CGPoint(x: 20, y: 20))
			path.addLine(to: CGPoint(x: self.bounds.midX, y: self.bounds.maxY - 20))
			path.addLine(to: CGPoint(x: self.bounds.maxX - 20, y: 20))
			bounce.path = path
			bounce.autoreverses = true
			bounce.repeatCount = Float.greatestFiniteMagnitude
			bounce.calculationMode = kCAAnimationCubic
			ball.add(bounce, forKey: "bounce")
			viewState += 1
		}
		else {
			
			jumping.removeTextLayers()
			
			let p = CGPoint(x: self.bounds.midX, y: -30)
			// Kill the bounce animation
			let stop = CABasicAnimation(keyPath: "position")
			stop.toValue = NSValue(cgPoint: p)
			ball.add(stop, forKey: "bounce")
			// Move the ball of the screen
			ball.position = p
			spadeAce.opacity = 1
			viewState = 0
		}
		
	}
}
