//
//  SlideBehavior.swift
//  SlideBehaviorNewVersion
//
//  Created by Seyed Samad Gholamzadeh on 11/12/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

class SlideBehavior: UIDynamicBehavior {
	
	let attachment: UIAttachmentBehavior
	let collisionBehavior: UICollisionBehavior
	let gravityBehavior: UIGravityBehavior
	let itemBehavior: UIDynamicItemBehavior
	private var slideAttachmentBehavior: UIAttachmentBehavior!
	fileprivate let item: UIDynamicItem
	
	// Enabling/disabling effectively adds or removes the item from the child behaviors.
	var isEnabled = true {
		didSet {
			if isEnabled {
				attachment.anchorPoint = item.center
				addChildBehavior(attachment)
			}
			else {
				removeChildBehavior(attachment)
			}
		}
	}
	
	var anchorPoint: CGPoint! {
		
		get {
			return self.attachment.anchorPoint
		}
		
		set {
			self.attachment.anchorPoint = newValue
		}
		
	}
	
	init(item: UIDynamicItem) {
		self.item = item
		
		gravityBehavior = UIGravityBehavior(items: [item])
		gravityBehavior.magnitude = 2.0
		
		collisionBehavior = UICollisionBehavior(items: [item])
		itemBehavior = UIDynamicItemBehavior(items: [item])
		itemBehavior.allowsRotation = false
		
		attachment = UIAttachmentBehavior(item: item, attachedToAnchor: item.center)

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
		
		let center = CGPoint(x: referenceView.bounds.width/2, y: referenceView.bounds.height/2)
		slideAttachmentBehavior = UIAttachmentBehavior.slidingAttachment(with: item, attachmentAnchor: center, axisOfTranslation: CGVector(dx: 0, dy: 1))
		addChildBehavior(slideAttachmentBehavior)
	}
	
	func addLinearVelocity(_ velocity: CGPoint) {
		self.gravityBehavior.removeItem(item)
		self.removeChildBehavior(slideAttachmentBehavior)
		itemBehavior.addLinearVelocity(velocity, for: item)
	}

		
	
}
