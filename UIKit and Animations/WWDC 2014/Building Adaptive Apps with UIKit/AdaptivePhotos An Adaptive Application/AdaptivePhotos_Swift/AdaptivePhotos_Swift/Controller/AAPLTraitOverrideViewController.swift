/*
Copyright (C) 2014 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:

A view controller container that forces its child to have different traits.

*/

import UIKit

class AAPLTraitOverrideViewController: UIViewController {

	var viewController: UIViewController! {
		didSet {
			guard self.viewController != nil else { return }
			if oldValue != nil {
				oldValue.willMove(toParentViewController: nil)
				self.setOverrideTraitCollection(nil, forChildViewController: oldValue)
				oldValue.view.removeFromSuperview()
				oldValue.removeFromParentViewController()
			}
			
			self.addChildViewController(self.viewController)
			
			let view = self.viewController.view!
			view.translatesAutoresizingMaskIntoConstraints = false
			self.view.addSubview(view)
			
			let views = ["view" : view]
			self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[view]|", options: NSLayoutFormatOptions(), metrics: nil, views: views))
			self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|", options: NSLayoutFormatOptions(), metrics: nil, views: views))
			self.viewController.didMove(toParentViewController: self)
			
			self.updateForcedTraitCollection()
		}
	}
	
	var forcedTraitCollection: UITraitCollection! {
		didSet {
			self.updateForcedTraitCollection()
		}
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		let hSizeClass =  coordinator.containerView.traitCollection.horizontalSizeClass
		let vSizeClass =  coordinator.containerView.traitCollection.verticalSizeClass

		if hSizeClass == .compact, vSizeClass == .compact {
			if size.width > size.height {
				// If we are large enough, force a regular size class
				self.forcedTraitCollection = UITraitCollection(horizontalSizeClass: .regular)
			}
			else {
				// Otherwise, don't override any traits
				self.forcedTraitCollection = nil
			}
		}
		
		super.viewWillTransition(to: size, with: coordinator)
	}
	
	func updateForcedTraitCollection() {
		// Use our forcedTraitCollection to override our child's traits
		self.setOverrideTraitCollection(self.forcedTraitCollection, forChildViewController: self.viewController)
	}
	
	override var shouldAutomaticallyForwardAppearanceMethods: Bool {
		return true
	}
}
