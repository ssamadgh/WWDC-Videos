//
//  SlideBehavior.swift
//  SlideBehavior
//
//  Created by Seyed Samad Gholamzadeh on 11/12/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

class SlideBehavior: UIDynamicBehavior {

	let collisionBehavior: UICollisionBehavior
	let gravityBehavior: UIGravityBehavior
	let itemBehavior: UIDynamicItemBehavior

	fileprivate let item: UIDynamicItem

	// Enabling/disabling effectively adds or removes the item from the child behaviors.
	var isEnabled = true {
		didSet {
			if isEnabled {
				gravityBehavior.addItem(item)
				collisionBehavior.addItem(item)
				itemBehavior.addItem(item)
			}
			else {
				gravityBehavior.removeItem(item)
				collisionBehavior.removeItem(item)
				itemBehavior.removeItem(item)
			}
		}
	}

	
	init(item: UIDynamicItem) {
		self.item = item
		
		gravityBehavior = UIGravityBehavior(items: [item])
		gravityBehavior.magnitude = 2.0
		
		collisionBehavior = UICollisionBehavior(items: [item])
		itemBehavior = UIDynamicItemBehavior(items: [item])
		itemBehavior.allowsRotation = false

		super.init()
		
		// Add each behavior as a child behavior.
		addChildBehavior(gravityBehavior)
		addChildBehavior(collisionBehavior)
		addChildBehavior(itemBehavior)

	}
	
	// MARK: UIDynamicBehavior
	
	override func willMove(to dynamicAnimator: UIDynamicAnimator?) {
		super.willMove(to: dynamicAnimator)
		
		guard let referenceView = dynamicAnimator?.referenceView else { return }
		let maxY = referenceView.bounds.maxY + 1
		let maxX = referenceView.bounds.maxX + 10
		
		collisionBehavior.addBoundary(withIdentifier: "reference bound" as NSCopying, from: CGPoint(x: 0, y: maxY), to: CGPoint(x: maxX, y: maxY))

	}
	
	func addLinearVelocity(_ velocity: CGPoint) {
		itemBehavior.addItem(item)
		itemBehavior.addLinearVelocity(velocity, for: item)
	}
	
	
}
