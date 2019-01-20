//
//  APLPositionToBoundsMapping.swift
//  DynamicsCatalog_Swift
//
//  Created by Seyed Samad Gholamzadeh on 6/30/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

protocol ResizableDynamicItem: UIDynamicItem {
	
	var bounds: CGRect { get set }
}
class APLPositionToBoundsMapping: NSObject, UIDynamicItem {

	var target: ResizableDynamicItem
	
	init(target: ResizableDynamicItem) {
		self.target = target
		
		super.init()
	}
	
	//MARK: -  UIDynamicItem
	
	//| ----------------------------------------------------------------------------
	//  Manual implementation of the getter for the bounds property required by
	//  UIDynamicItem.
	//
	var bounds: CGRect {
		// Pass through
		return self.target.bounds
	}
	
	
	//| ----------------------------------------------------------------------------
	//  Manual implementation of the getter for the center property required by
	//  UIDynamicItem.
	//  Manual implementation of the setter for the center property required by
	//  UIDynamicItem.

	var center: CGPoint {
		get {
			// center.x <- bounds.size.width, center.y <- bounds.size.height
			return CGPoint(x: self.target.bounds.size.width, y: self.target.bounds.size.height);
		}
		
		set {
			// center.x -> bounds.size.width, center.y -> bounds.size.height
			self.target.bounds = CGRect(x: 0, y: 0, width: newValue.x, height: newValue.y);
		}
	}
	
	//| ----------------------------------------------------------------------------
	//  Manual implementation of the getter for the transform property required by
	//  UIDynamicItem.
	//
	//| ----------------------------------------------------------------------------
	//  Manual implementation of the setter for the transform property required by
	//  UIDynamicItem.
	//
	var transform: CGAffineTransform {
		get {
			// Pass through
			return self.target.transform
		}
		
		set {
			// Pass through
			self.target.transform = newValue
		}
	}
	
}
