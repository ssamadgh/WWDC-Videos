/*
Copyright (C) 2014 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:

An extension that gives information about how view controllers will be shown, for determining disclosure indicator visibility and row deselection.

*/

import UIKit


extension UIViewController {
	
	// Returns whether calling showViewController:sender: would cause a navigation "push" to occur
	@objc func aapl_willShowingViewControllerPush(sender: Any) -> Bool {
		
		// Find and ask the right view controller about showing
		
		if let target = self.targetViewController(forAction: #selector(aapl_willShowingViewControllerPush(sender:)), sender: sender) {
			return target.aapl_willShowingViewControllerPush(sender:sender)
		} else {
			// Or if we can't find one, we won't be pushing
			return false
		}
	}
	
	// Returns whether calling showDetailViewController:sender: would cause a navigation "push" to occur
	@objc func aapl_willShowingDetailViewControllerPush(sender: Any) -> Bool {
		
		// Find and ask the right view controller about showing detail
		if let target = self.targetViewController(forAction: #selector(aapl_willShowingDetailViewControllerPush(sender:)), sender: sender) {
			return target.aapl_willShowingDetailViewControllerPush(sender:sender)
		} else {
			// Or if we can't find one, we won't be pushing
			return false
		}
	}

}

extension UINavigationController {
	
	override func aapl_willShowingViewControllerPush(sender: Any) -> Bool {
		// Navigation Controllers always push for showViewController:
		return true
	}
}

extension UISplitViewController {
	
	override func aapl_willShowingViewControllerPush(sender: Any) -> Bool {
		// Split View Controllers always push for showViewController:
		return false
	}
	
	override func aapl_willShowingDetailViewControllerPush(sender: Any) -> Bool {
		if self.isCollapsed {
			// If we're collapsed, re-ask this question as showViewController: to our primary view controller
			let target = self.viewControllers.last!
			return target.aapl_willShowingViewControllerPush(sender: sender)
		} else {
			// Otherwise, we don't push for showDetailViewController:
			return false
		}
	}
}
