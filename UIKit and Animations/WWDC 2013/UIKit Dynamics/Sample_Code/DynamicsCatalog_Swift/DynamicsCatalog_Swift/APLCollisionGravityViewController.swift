//
//  APLCollisionGravityViewController.swift
//  DynamicsCatalog_Swift
//
//  Created by Seyed Samad Gholamzadeh on 6/27/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.

// Abstract: Provides the "Collision + Gravity" demonstration.


import UIKit

class APLCollisionGravityViewController: UIViewController, UICollisionBehaviorDelegate {

	@IBOutlet weak var square1: UIImageView!

	var animator: UIDynamicAnimator!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		// Make the square a template image so its color can be changed
		// by adjusting the tintColor of the UIImageView displaying it.
		let image = self.square1.image!.withRenderingMode(.alwaysTemplate)
		self.square1.image = image
		self.square1.tintColor = UIColor.darkGray
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		
		let animator = UIDynamicAnimator(referenceView: self.view)
		let gravityBehavior = UIGravityBehavior(items: [self.square1])
		animator.addBehavior(gravityBehavior)

		let collisionBehavior = UICollisionBehavior(items: [self.square1])
		// Creates collision boundaries from the bounds of the dynamic animator's
		// reference view (self.view).
//		collisionBehavior.translatesReferenceBoundsIntoBoundary = true
		collisionBehavior.addBoundary(withIdentifier: "reference bound" as NSCopying, for: UIBezierPath(rect: self.view.bounds))
		collisionBehavior.collisionDelegate = self
		animator.addBehavior(collisionBehavior)
		
		self.animator = animator

	}
	
	
	//| ----------------------------------------------------------------------------
	//  This method is called when square1 begins contacting a collision boundary.
	//  In this demo, the only collision boundary is the bounds of the reference
	//  view (self.view).
	//
	func collisionBehavior(_ behavior: UICollisionBehavior, beganContactFor item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying?, at p: CGPoint) {
		// Lighten the tint color when the view is in contact with a boundary.
		(item as! UIView).tintColor = UIColor.lightGray
	}
	
	//| ----------------------------------------------------------------------------
	//  This method is called when square1 stops contacting a collision boundary.
	//  In this demo, the only collision boundary is the bounds of the reference
	//  view (self.view).
	//
	func collisionBehavior(_ behavior: UICollisionBehavior, endedContactFor item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying?) {
		// Restore the default color when ending a contcact.
		(item as! UIView).tintColor = UIColor.darkGray
	}
	
	
}
