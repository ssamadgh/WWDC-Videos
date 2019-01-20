//
//  APLCompositeBehaviorViewController.swift
//  DynamicsCatalog_Swift
//
//  Created by Seyed Samad Gholamzadeh on 6/30/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

class APLCompositeBehaviorViewController: UIViewController {

	@IBOutlet weak var square: UIView!
	@IBOutlet weak var attachmentPoint: UIImageView!
	var animator: UIDynamicAnimator!
	var pendulumBehavior: APLPendulumBehavior!

    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.attachmentPoint.tintColor = .red
		self.attachmentPoint.image = self.attachmentPoint.image?.withRenderingMode(.alwaysTemplate)
		
		
		// Visually show the connection between the attachmentPoint and the square.
		(self.view as! APLDecorationView).trackAndDrawAttachmentFromView(self.attachmentPoint, to: self.square, withAttachmentOffset: CGPoint(x: 0, y: (-0.95 * self.square.bounds.size.height/2)))

		let animator = UIDynamicAnimator(referenceView: self.view)
		
		let pendulumAttachmentPoint = self.attachmentPoint.center
		
		// An example of a high-level behavior simulating a simple pendulum.
		let pendulumBehavior = APLPendulumBehavior(weight: self.square, suspendedFromPoint: pendulumAttachmentPoint)
		animator.addBehavior(pendulumBehavior)
		self.pendulumBehavior = pendulumBehavior
		
		self.animator = animator
	}


	//| ----------------------------------------------------------------------------
	//  IBAction for the Pan Gesture Recognizer that has been configured to track
	//  touches in self.view.
	//
	@IBAction func dragWeight(_ gesture: UIPanGestureRecognizer) {
		
		if gesture.state == .began {
			self.pendulumBehavior.beginDraggingWeight(at: gesture.location(in: self.view))
		}
		else if gesture.state == .ended {
			self.pendulumBehavior.endDraggingWeight(withVelocity: gesture.velocity(in: self.view))
		}
		else if gesture.state == .cancelled {
			gesture.isEnabled = true
			self.pendulumBehavior.endDraggingWeight(withVelocity: gesture.velocity(in: self.view))
		}
		else if !self.square.bounds.contains(gesture.location(in: self.view)) {
			// End the gesture if the user's finger moved outside square1's bounds.
			// This causes the gesture to transition to the cencelled state.
			gesture.isEnabled = false
		}
		else {
			self.pendulumBehavior.dragWeight(to: gesture.location(in: self.view))
		}
	}

}
