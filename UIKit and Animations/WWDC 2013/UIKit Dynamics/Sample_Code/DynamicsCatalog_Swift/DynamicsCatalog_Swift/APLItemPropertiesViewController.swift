//
//  APLItemPropertiesViewController.swift
//  DynamicsCatalog_Swift
//
//  Created by Seyed Samad Gholamzadeh on 6/30/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

class APLItemPropertiesViewController: UIViewController {

	@IBOutlet weak var square1: UIView!
	@IBOutlet weak var square2: UIView!
	var square1PropertiesBehavior: UIDynamicItemBehavior!
	var square2PropertiesBehavior: UIDynamicItemBehavior!
	var animator: UIDynamicAnimator!

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		let animator = UIDynamicAnimator(referenceView: self.view)
		
		// We want to show collisions between views and boundaries with different
		// elasticities, we thus associate the two views to gravity and collision
		// behaviors. We will only change the restitution parameter for one of these
		// views.
		let gravityBehavior = UIGravityBehavior(items: [self.square1, self.square2])
		let collisionBehavior = UICollisionBehavior(items: [self.square1, self.square2])
		collisionBehavior.translatesReferenceBoundsIntoBoundary = true
		
		// A dynamic item behavior gives access to low-level properties of an item
		// in Dynamics, here we change restitution on collisions only for square2,
		// and keep square1 with its default value.
		self.square2PropertiesBehavior = UIDynamicItemBehavior(items: [self.square2])
		self.square2PropertiesBehavior.elasticity = 0.5
		
		// A dynamic item behavior is created for square1 so it's velocity can be
		// manipulated in the -resetAction: method.
		self.square1PropertiesBehavior = UIDynamicItemBehavior(items: [self.square1])

		animator.addBehavior(self.square1PropertiesBehavior)
		animator.addBehavior(self.square2PropertiesBehavior)
		animator.addBehavior(gravityBehavior)
		animator.addBehavior(collisionBehavior)
		
		self.animator = animator

	}
	
	//| ----------------------------------------------------------------------------
	//  IBAction for the "Replay" bar button item used to restart the demo.
	//
	@IBAction func replayAction(_ sender: Any) {
		
		// Moving an item does not reset its velocity.  Here we do that manually
		// using the dynamic item behaviors, adding the inverse velocity for each
		// square.
		self.square1PropertiesBehavior.addLinearVelocity(CGPoint(x: 0, y: -1*(self.square1PropertiesBehavior.linearVelocity(for: self.square1).y)), for: self.square1)
		self.square1.center = CGPoint(x: 90, y: 171)
		self.animator.updateItem(usingCurrentState: self.square1)
		
		self.square2PropertiesBehavior.addLinearVelocity(CGPoint(x: 0, y: -1*(self.square2PropertiesBehavior.linearVelocity(for: self.square2).y)), for: self.square2)
		self.square2.center = CGPoint(x: 230, y: 171)
		self.animator.updateItem(usingCurrentState: self.square2)
	}

}
