//
//  UIViewController+AAPLPhotoContents.swift
//  AdaptivePhotos_Swift
//
//  Created by Seyed Samad Gholamzadeh on 7/24/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit


extension UIViewController {
	
	@objc var aapl_containedPhoto: AAPLPhoto? {
		// By default, view controllers don't contain photos
		return nil
	}
	
	@objc func aapl_contains(_ photo: AAPLPhoto) -> Bool {
		// By default, view controllers don't contain photos
		return false
	}
	
	@objc func aapl_currentVisibleDetailPhoto(sender: Any) -> AAPLPhoto? {
		// Look for a view controller that has a visible photo
		if let target = self.targetViewController(forAction: #selector(aapl_currentVisibleDetailPhoto(sender:)), sender: sender) {
			return target.aapl_currentVisibleDetailPhoto(sender: sender)
		}
		else {
			return nil
		}
	}
	
}

extension UISplitViewController {
	
	override func aapl_currentVisibleDetailPhoto(sender: Any) -> AAPLPhoto? {
		if self.isCollapsed {
			// If we're collapsed, we don't have a detail
			return nil
		} else {
			// Otherwise, return our detail controller's contained photo (if any)
			let controller = self.viewControllers.last
			return controller?.aapl_containedPhoto
		}
	}
}
