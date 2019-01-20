//
//  APLSnapViewController.swift
//  DynamicsCatalog_Swift
//
//  Created by Seyed Samad Gholamzadeh on 6/28/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

class APLSnapViewController: UIViewController {

	@IBOutlet weak var square1: UIImageView!
	//! The view that displays the attachment point on square1.
	var animator: UIDynamicAnimator!
	var snapBehavior: UISnapBehavior!
	
    override func viewDidLoad() {
        super.viewDidLoad()

		let animator = UIDynamicAnimator(referenceView: self.view)
		self.animator = animator
    }

	//| ----------------------------------------------------------------------------
	//  IBAction for the Tap Gesture Recognizer that has been configured to track
	//  touches in self.view.
	//
	@IBAction func handleSnapGesture(_ gesture: UITapGestureRecognizer) {
		
		let point = gesture.location(in: self.view)
		
		// Remove the previous behavior.
		if self.snapBehavior != nil {
			self.animator.removeBehavior(self.snapBehavior)
		}

		let snapBehavior = UISnapBehavior(item: self.square1, snapTo: point)
		self.animator.addBehavior(snapBehavior)
		self.snapBehavior = snapBehavior
	}
	
}
