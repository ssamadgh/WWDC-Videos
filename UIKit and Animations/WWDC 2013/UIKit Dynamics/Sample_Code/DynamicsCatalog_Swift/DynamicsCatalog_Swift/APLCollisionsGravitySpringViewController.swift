//
//  APLCollisionsGravitySpringViewController.swift
//  DynamicsCatalog_Swift
//
//  Created by Seyed Samad Gholamzadeh on 6/28/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

class APLCollisionsGravitySpringViewController: UIViewController {

	@IBOutlet weak var square1: UIImageView!
	//! The view that displays the attachment point on square1.
	@IBOutlet weak var square1AttachmentView: UIImageView!
	//! The view that the user drags to move square1.
	@IBOutlet weak var attachmentView: UIImageView!
	var animator: UIDynamicAnimator!
	var attachmentBehavior: UIAttachmentBehavior!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let animator = UIDynamicAnimator(referenceView: self.view)
		let gravityBehavior = UIGravityBehavior(items: [self.square1])
		let collisionBehavior = UICollisionBehavior(items: [self.square1])
		
		let anchorPoint = CGPoint(x: self.square1.center.x, y: self.square1.center.y - 110)
		
		let attachmentBehavior = UIAttachmentBehavior(item: self.square1, attachedToAnchor: anchorPoint)
		
		collisionBehavior.translatesReferenceBoundsIntoBoundary = true

		// These parameters set the attachment in spring mode, instead of a rigid
		// connection.
		attachmentBehavior.frequency = 1.0
		attachmentBehavior.damping = 0.1
		self.attachmentBehavior = attachmentBehavior

		// Visually show the attachment points
		self.attachmentView.center = attachmentBehavior.anchorPoint
		self.attachmentView.tintColor = UIColor.red
		self.attachmentView.image = self.attachmentView.image?.withRenderingMode(.alwaysTemplate)
		self.attachmentView.center = attachmentBehavior.anchorPoint;

		self.square1AttachmentView.center = CGPoint(x: 50.0, y: 50.0)
		self.square1AttachmentView.tintColor = UIColor.blue
		self.square1AttachmentView.image = self.square1AttachmentView.image?.withRenderingMode(.alwaysTemplate)
		
		// Visually show the connection between the attachment points.
		(self.view as! APLDecorationView).trackAndDrawAttachmentFromView(self.attachmentView, to: self.square1, withAttachmentOffset: CGPoint.zero)
		
		animator.addBehavior(attachmentBehavior)
		animator.addBehavior(gravityBehavior)
		animator.addBehavior(collisionBehavior)

		self.animator = animator;
	}
	
	//| ----------------------------------------------------------------------------
	//  IBAction for the Pan Gesture Recognizer and Tap Gesture Recognizer that have
	//  been configured to track touches in self.view.  (Both types of gesture
	//  recognizers are used so that square1AttachmentView is repositioned
	//  immediately in response to a new touch, instead of waiting for that touch
	//  to be recognized as a drag.)
	//
	@IBAction func handleSpringAttachmentGesture(_ gesture: UIGestureRecognizer) {
		self.attachmentBehavior.anchorPoint = gesture.location(in: self.view)
		self.attachmentView.center = self.attachmentBehavior.anchorPoint
	}

}
