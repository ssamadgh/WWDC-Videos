//
//  APLInstantaneousPushViewController.swift
//  DynamicsCatalog_Swift
//
//  Created by Seyed Samad Gholamzadeh on 6/29/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

class APLInstantaneousPushViewController: UIViewController {

	
	@IBOutlet weak var square1: UIView!
	var animator: UIDynamicAnimator!
	var pushBehavior: UIPushBehavior!
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		let animator = UIDynamicAnimator(referenceView: self.view)

		let collisionBehavior = UICollisionBehavior(items: [self.square1])
		
		// Account for any top and bottom bars when setting up the reference bounds.
		collisionBehavior.setTranslatesReferenceBoundsIntoBoundary(with: UIEdgeInsets(top: self.view.safeAreaInsets.top, left: 0, bottom: self.view.safeAreaInsets.bottom, right: 0))
		animator.addBehavior(collisionBehavior)
		
		let pushBehavior = UIPushBehavior(items: [self.square1], mode: .instantaneous)
		pushBehavior.angle = 0.0
		pushBehavior.magnitude = 0.0
		animator.addBehavior(pushBehavior)
		self.pushBehavior = pushBehavior
		
		self.animator = animator
	}


	//| ----------------------------------------------------------------------------
	//  IBAction for the Tap Gesture Recognizer that has been configured to track
	//  touches in self.view.
	//
	@IBAction func handlePushGesture(_ gesture: UITapGestureRecognizer) {
		
	// Tapping will change the angle and magnitude of the impulse. To visually
	// show the impulse vector on screen, a red arrow representing the angle
	// and magnitude of this vector is briefly drawn.
		let p = gesture.location(in: self.view)
		let o = CGPoint(x: self.view.bounds.midX, y: self.view.bounds.midY)
		var distance = sqrt(pow(p.x-o.x, 2.0) + pow(p.y-o.y, 2.0))
		let angle = atan2(p.y-o.y, p.x-o.x)
		distance = min(distance, 100.0)
	
	// Display an arrow showing the direction and magnitude of the applied
	// impulse.
		(self.view as! APLDecorationView).drawMagnitudeVectorWithLength(distance, angle: angle, color: .red, forLimitedTime: true)
	
	// These two lines change the actual force vector.
		self.pushBehavior.magnitude = distance/100.0
		self.pushBehavior.angle = angle
		
	// A push behavior in instantaneous (impulse) mode automatically
	// deactivate itself after applying the impulse. We thus need to reactivate
	// it when changing the impulse vector.
		self.pushBehavior.active = true
	}

}
