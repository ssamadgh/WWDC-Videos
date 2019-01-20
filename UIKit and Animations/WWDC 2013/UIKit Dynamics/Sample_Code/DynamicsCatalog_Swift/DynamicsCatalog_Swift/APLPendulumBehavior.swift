//
//  APLPendulumBehavior.swift
//  DynamicsCatalog_Swift
//
//  Created by Seyed Samad Gholamzadeh on 6/30/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

class APLPendulumBehavior: UIDynamicBehavior {
	
	var  draggingBehavior: UIAttachmentBehavior!
	var  pushBehavior: UIPushBehavior!
	
	
	//| ----------------------------------------------------------------------------
	//! Initializes and returns a newly allocated APLPendulumBehavior which suspends
	//! @a item hanging from @a p at a fixed distance (derived from the current
	//! distance from @a item to @a p.).
	//
	init(weight item: UIDynamicItem, suspendedFromPoint p: CGPoint) {
		super.init()
		
		// The high-level pendulum behavior is built from 2 primitive behaviors.
		let gravityBehavior = UIGravityBehavior(items: [item])
		let atttachmentBehavior = UIAttachmentBehavior(item: item, attachedToAnchor: p)

		
		// These primative behaviors allow the user to drag the pendulum weight.
		let draggingBehavior = UIAttachmentBehavior(item: item, attachedToAnchor: .zero)
		let pushBehavior = UIPushBehavior(items: [item], mode: .instantaneous)
		pushBehavior.active = false
		
		self.addChildBehavior(gravityBehavior)
		self.addChildBehavior(atttachmentBehavior)
		
		self.addChildBehavior(pushBehavior)

		// The draggingBehavior is added as needed, when the user begins dragging
		// the weight.
		
		self.draggingBehavior = draggingBehavior
		self.pushBehavior = pushBehavior
		
	}
	
	//| ----------------------------------------------------------------------------
	func beginDraggingWeight(at point: CGPoint) {
		self.draggingBehavior.anchorPoint = point
		self.addChildBehavior(self.draggingBehavior)
	}
	
	
	//| ----------------------------------------------------------------------------
	func dragWeight(to point: CGPoint) {
		self.draggingBehavior.anchorPoint = point
	}
	
	//| ----------------------------------------------------------------------------
	func endDraggingWeight(withVelocity v: CGPoint) {
		var magnitude: CGFloat = sqrt(pow(v.x, 2.0) + pow(v.y, 2.0))
		let angle: CGFloat = atan2(v.y, v.x)
		
		// Reduce the volocity to something meaningful.  (Prevents the user from
		// flinging the pendulum weight).
		magnitude /= 500
		
		self.pushBehavior.angle = angle
		self.pushBehavior.magnitude = magnitude
		self.pushBehavior.active = true
		
		self.removeChildBehavior(self.draggingBehavior)
	}

}
