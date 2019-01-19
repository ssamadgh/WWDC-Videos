//
//  ImageLabel.swift
//  UIKitRendering
//
//  Created by Seyed Samad Gholamzadeh on 8/24/1396 AP.
//  Copyright © 1396 AP Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

class ImageLabel: UIView {

	var label: UILabel
	
	
	 init(frame: CGRect, title: String, isReflection: Bool = false) {
		self.label = UILabel()
		super.init(frame: frame)

		self.isOpaque = false
		self.label.frame = self.bounds.insetBy(dx: 20, dy: 5)
		self.label.backgroundColor = UIColor.clear
		self.label.textAlignment = .center
		self.label.font = UIFont.boldSystemFont(ofSize: 28)
		self.label.layer.shadowOffset = CGSize(width: 3, height: 3)
		self.label.layer.shadowColor = UIColor.black.cgColor
		self.label.layer.shadowOpacity = 0.4
		self.label.text = title
		self.layer.cornerRadius = self.bounds.height/2
		self.layer.masksToBounds = true
		self.backgroundColor = UIColor.gray
//		self.alpha = 0.5
		self.addSubview(label)
		self.alpha = 0.5 // group opacity
		self.addReflection(isReflection: isReflection)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	
	func addReflection(isReflection: Bool) {
		
		if isReflection, self.layer.mask == nil {
			let maskLayer = CALayer(layer: self.layer)
			maskLayer.frame = self.bounds
			
			UIGraphicsBeginImageContext(self.bounds.size)
			let context = UIGraphicsGetCurrentContext()
			let deviceGray = CGColorSpaceCreateDeviceGray()
			let locations: [CGFloat] = [1.0, 0.0]
			let colors = [UIColor(white: 0, alpha: 0.0).cgColor, UIColor(white: 0, alpha: 0.5).cgColor]
			
			let gradient = CGGradient(colorsSpace: deviceGray, colors: colors as CFArray, locations: locations)!
			
			context?.drawLinearGradient(gradient, start: CGPoint(x: 0, y: 0), end: CGPoint(x: 0, y: self.bounds.size.height), options: CGGradientDrawingOptions(rawValue: 0))
			
			maskLayer.contents = context?.makeImage()
			self.layer.mask = maskLayer
			
			self.layer.isGeometryFlipped = true

		}
	}

}
