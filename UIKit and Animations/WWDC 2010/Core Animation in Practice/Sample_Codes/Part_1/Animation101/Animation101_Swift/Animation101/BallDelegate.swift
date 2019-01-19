//
//  BallDelegate.swift
//  Animation101
//
//  Created by Seyed Samad Gholamzadeh on 3/7/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

class BallDelegate: NSObject, CALayerDelegate, CAAnimationDelegate {

	var parent: RootView!
	
	func draw(_ layer: CALayer, in ctx: CGContext) {
		
		ctx.saveGState()
		let bounds = layer.bounds
		let clipPath = CGMutablePath()
		clipPath.addEllipse(in: CGRect(x: 0.5, y: 0.5, width: bounds.size.width - 1, height: bounds.size.height - 1))
		ctx.addPath(clipPath)
		ctx.clip()
		
		let colorSpace = CGColorSpaceCreateDeviceRGB()
		let num_locations: Int = 2
		let locations: [CGFloat] = [0.0, 1.0]
		let components: [CGFloat] = [0.9, 0.1,0, 1.0,  // Start color
			0.3, 0.1, 0, 1.0] // End color
		let gradient = CGGradient(colorSpace: colorSpace, colorComponents: components, locations: locations, count: num_locations)!
		
		let startPoint: CGPoint = CGPoint(x: bounds.midX - 12, y: bounds.midY - 10)
		let endPoint: CGPoint = CGPoint(x: bounds.midX, y: bounds.midY)
		let startRadius: CGFloat = 0
		let endRadius: CGFloat = bounds.width/2
		ctx.drawRadialGradient(gradient, startCenter: startPoint, startRadius: startRadius, endCenter: endPoint, endRadius: endRadius, options: CGGradientDrawingOptions.drawsAfterEndLocation)
		ctx.restoreGState()
	}
	
	func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
		self.parent.scatterLetters()
	}
	

}
