//
//  APLAttachmentsViewController.swift
//  DynamicsCatalog_Swift
//
//  Created by Seyed Samad Gholamzadeh on 6/27/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

class APLAttachmentsViewController: UIViewController {

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
		
		let collisionBehavior = UICollisionBehavior(items: [self.square1])
		
		// Creates collision boundaries from the bounds of the dynamic animator's
		// reference view (self.view).
		collisionBehavior.translatesReferenceBoundsIntoBoundary = true
		animator.addBehavior(collisionBehavior)
		
		let squareCenterPoint = CGPoint(x: self.square1.center.x, y: self.square1.center.y - 110)
		let attachmentPoint = UIOffset(horizontal: -25.0, vertical: -25.0)
		
		// By default, an attachment behavior uses the center of a view. By using a
		// small offset, we get a more interesting effect which will cause the view
		// to have rotation movement when dragging the attachment.
		let attachmentBehavior = UIAttachmentBehavior(item: self.square1, offsetFromCenter: attachmentPoint, attachedToAnchor: squareCenterPoint)
		animator.addBehavior(attachmentBehavior)
		self.attachmentBehavior = attachmentBehavior
		
		// Visually show the attachment points
		self.attachmentView.center = attachmentBehavior.anchorPoint
		self.attachmentView.tintColor = UIColor.red
		self.attachmentView.image = self.attachmentView.image?.withRenderingMode(.alwaysTemplate)
		self.attachmentView.center = attachmentBehavior.anchorPoint;
		
		self.square1AttachmentView.center = CGPoint(x: 25.0, y: 25.0)
		self.square1AttachmentView.tintColor = UIColor.blue
		self.square1AttachmentView.image = self.square1AttachmentView.image?.withRenderingMode(.alwaysTemplate)
		
		// Visually show the connection between the attachment points.
		(self.view as! APLDecorationView).trackAndDrawAttachmentFromView(self.attachmentView, to: self.square1, withAttachmentOffset: CGPoint(x: -25.0, y: -25.0))
		
		self.animator = animator;
    }


	//| ----------------------------------------------------------------------------
	//  IBAction for the Pan Gesture Recognizer that has been configured to track
	//  touches in self.view.
	//
	@IBAction func handleAttachmentGesture(_ gesture: UIPanGestureRecognizer) {
		self.attachmentBehavior.anchorPoint = gesture.location(in: self.view)
		self.attachmentView.center = self.attachmentBehavior.anchorPoint
	}
}
