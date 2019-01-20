//
//  APLCustomDynamicItemViewController.swift
//  DynamicsCatalog_Swift
//
//  Created by Seyed Samad Gholamzadeh on 6/30/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

class CustomButton: UIButton, ResizableDynamicItem {
	
	
}

class APLCustomDynamicItemViewController: UIViewController {

	@IBOutlet weak var button1: CustomButton!
	var button1Bounds: CGRect!
	var animator: UIDynamicAnimator!

	override func viewDidLoad() {
        super.viewDidLoad()
		// Save the button's initial bounds.  This is necessary so that the bounds
		// can be reset to their initial state before starting a new simulation.
		// Otherwise, the new simulation will continue from the bounds set in the
		// final step of the previous simulation which may have been interrupted
		// before it came to rest (e.g. the user tapped the button twice in quick
		// succession).  Without reverting to the initial bounds, this would cause
		// the button to grow uncontrollably in size.
		self.button1Bounds = self.button1.bounds
		
		// Force the button image to scale with its bounds.
		self.button1.contentHorizontalAlignment = UIControlContentHorizontalAlignment.fill
		self.button1.contentVerticalAlignment = UIControlContentVerticalAlignment.fill
    }

	//| ----------------------------------------------------------------------------
	//  IBAction for tapping the button in this demo.
	//
	@IBAction func buttonAction(_ sender: Any) {

	// Reset the buttons bounds to their initial state.  See the comment in
	// -viewDidLoad.
	self.button1.bounds = self.button1Bounds
	
	// UIDynamicAnimator instances are relatively cheap to create.
		let animator = UIDynamicAnimator(referenceView: self.view)
	
	// APLPositionToBoundsMapping maps the center of an id<ResizableDynamicItem>
	// (UIDynamicItem with mutable bounds) to its bounds.  As dynamics modifies
	// the center.x, the changes are forwarded to the bounds.size.width.
	// Similarly, as dynamics modifies the center.y, the changes are forwarded
	// to bounds.size.height.
		let buttonBoundsDynamicItem = APLPositionToBoundsMapping(target: sender as! ResizableDynamicItem)

		// Create an attachment between the buttonBoundsDynamicItem and the initial
	// value of the button's bounds.
		let attachmentBehavior = UIAttachmentBehavior(item: buttonBoundsDynamicItem, attachedToAnchor: buttonBoundsDynamicItem.center)
		attachmentBehavior.frequency = 2.0
		attachmentBehavior.damping = 0.3
		animator.addBehavior(attachmentBehavior)

		let pushBehavior = UIPushBehavior(items: [buttonBoundsDynamicItem], mode: .instantaneous)
		pushBehavior.angle = CGFloat.pi/4
		pushBehavior.magnitude = 2.0
		animator.addBehavior(pushBehavior)
		
		pushBehavior.active = true
		
		self.animator = animator
	}
}
