//
//  SampleView.swift
//  UIKitRendering
//
//  Created by Seyed Samad Gholamzadeh on 8/25/1396 AP.
//  Copyright © 1396 AP Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

class SampleView: UIView {

//     Only override draw() if you perform custom drawing.
//     An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
//         Drawing code
		self.backgroundColor = UIColor.white
		// Create a context for the mask
		let colorSpace = CGColorSpaceCreateDeviceGray()
		let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue)
		let maskContext = CGContext(data: nil, width: Int(rect.size.width), height: Int(rect.size.height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)!
		
		// Fill with black
		maskContext.setFillColor(UIColor.black.cgColor)
		maskContext.fill(rect)
		
		// Draw an arc in white
		maskContext.setLineWidth(20)
		maskContext.setStrokeColor(UIColor.white.cgColor)
		maskContext.addArc(center: CGPoint(x: rect.midX, y: rect.midY), radius: 50, startAngle: CGFloat.pi, endAngle: 0, clockwise: false)
		maskContext.strokePath()
		
		// Create the mask image from the context, and discard the context
		let mask = maskContext.makeImage()
		
		// Now draw into the view itself
		let context = UIGraphicsGetCurrentContext()
		
		// Apply the mask
		context?.clip(to: rect, mask: mask!)
		
		// Then draw something that overlaps the mask
		context?.setFillColor(UIColor.blue.cgColor)
		context?.fill(rect)
    }

}
