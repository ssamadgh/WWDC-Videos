//
//  ImageLabelFast.swift
//  UIKitRendering
//
//  Created by Seyed Samad Gholamzadeh on 8/25/1396 AP.
//  Copyright © 1396 AP Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

class ImageLabelFast: UIView {
	
	
	var labelTitle: String?
	var isReflection: Bool
	
	init(frame: CGRect, title: String, isReflection: Bool = false) {
		self.labelTitle = title
		self.isReflection = isReflection
		
		super.init(frame: frame)
		self.backgroundColor = UIColor.clear
		
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	
	override func draw(_ rect: CGRect) {
		self.draw()
		self.alpha = 0.5

	}
	
	
	func draw() {
		let myBounds = self.bounds
		let context = UIGraphicsGetCurrentContext()!
		
		if self.isReflection {
			UIGraphicsBeginImageContext(self.bounds.size)
			let maskContext = UIGraphicsGetCurrentContext()!
			
			let deviceGray = CGColorSpaceCreateDeviceGray()
			
			let locations: [CGFloat] = [1.0, 0.0]
			let colors = [UIColor(white: 0, alpha: 0.0).cgColor, UIColor(white: 0, alpha: 0.5).cgColor]
			
			let gradient = CGGradient(colorsSpace: deviceGray, colors: colors as CFArray, locations: locations)!
			
			maskContext.drawLinearGradient(gradient, start: CGPoint(x: 0, y: 0), end: CGPoint(x: 0, y: self.bounds.size.height), options: CGGradientDrawingOptions(rawValue: 0))
			
			
			let maskImage = maskContext.makeImage()!
			UIGraphicsEndImageContext()
			
			context.clip(to: myBounds, mask: maskImage)
			// only applied once
			self.transform = CGAffineTransform(scaleX: 1, y: -1)

		}
		

		// draw background // we don't need the mask (over kill)
		let capsulePath = UIBezierPath(roundedRect: myBounds, cornerRadius: myBounds.height/2)
		UIColor.gray.set()
		capsulePath.fill()

		// text
		let attrs = [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 28)]
		let labelSize = self.labelTitle!.size(withAttributes: attrs)
		
		let titleFrame = CGRect(x: (myBounds.size.width - labelSize.width)/2, y: (myBounds.size.height - labelSize.height)/2, width: labelSize.width, height: labelSize.height)
		
		// text shadow
		context.setShadow(offset: CGSize(width: 3.0, height: 3.0), blur: 10.0)
		context.setShadow(offset: CGSize(width: 3.0, height: 3.0), blur: 10.0, color: UIColor(white: 0.0, alpha: 0.4).cgColor)
		
		UIColor.black.set()
		
		self.labelTitle!.draw(with: titleFrame, options: .usesLineFragmentOrigin, attributes: attrs, context: nil)
	}
	
	
}
