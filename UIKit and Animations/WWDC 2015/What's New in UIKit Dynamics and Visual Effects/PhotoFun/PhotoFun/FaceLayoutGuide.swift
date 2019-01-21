//
//  FaceLayoutGuide.swift
//  PhotoFun
//
//  Created by Seyed Samad Gholamzadeh on 11/12/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

class FaceLayoutGuide: UILayoutGuide {
	
	private class FaceLayoutGuideDynamicItem: NSObject, UIDynamicItem {
		let horizontal: Bool
		required init(horizontal: Bool) {
			self.horizontal = horizontal
			super.init()
		}
		private var constant: CGFloat {
			get {
				return horizontal ? center.x : center.y
			}
		}
		
		var constraint: NSLayoutConstraint? {
			didSet {
				if let c = constraint {
					c.constant = constant
					c.isActive = true
				}
			}
		}
		
		@objc var center: CGPoint = .zero {
			didSet {
				if let c = constraint {
					c.constant = constant
				}
			}
		}
		
		@objc let bounds = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
		@objc var transform = CGAffineTransform.identity
	}
	
	private var positionItem = FaceLayoutGuideDynamicItem(horizontal: false)
	private var topItem = FaceLayoutGuideDynamicItem(horizontal: false)
	private var bottomItem = FaceLayoutGuideDynamicItem(horizontal: false)
	private var leftItem = FaceLayoutGuideDynamicItem(horizontal: true)
	private var rightItem = FaceLayoutGuideDynamicItem(horizontal: true)
	
	lazy private var itemBehavior: UIDynamicItemBehavior = {
		let itemBehavior = UIDynamicItemBehavior(items: [self.topItem, self.bottomItem, self.leftItem, self.rightItem])
		itemBehavior.allowsRotation = true
		return itemBehavior
	}()
	
	lazy private var anchoredItemBehavior: UIDynamicItemBehavior = {
		let itemBehavior = UIDynamicItemBehavior(items: [self.positionItem])
		itemBehavior.allowsRotation = false
		itemBehavior.isAnchored = true
		return itemBehavior
	}()
	
	lazy private var topSlider: UIAttachmentBehavior = UIAttachmentBehavior.slidingAttachment(with: self.topItem, attachedTo: self.positionItem, attachmentAnchor: self.position, axisOfTranslation: CGVector(dx: 0.0, dy: 1.0))
	lazy private var bottomSlider: UIAttachmentBehavior = UIAttachmentBehavior.slidingAttachment(with: self.bottomItem, attachedTo: self.positionItem, attachmentAnchor: self.position, axisOfTranslation: CGVector(dx: 0.0, dy: -1.0))
	lazy private var leftSlider: UIAttachmentBehavior = UIAttachmentBehavior.slidingAttachment(with: self.leftItem, attachedTo: self.positionItem, attachmentAnchor: self.position, axisOfTranslation: CGVector(dx: 1.0, dy: 0.0))
	lazy private var rightSlider: UIAttachmentBehavior = UIAttachmentBehavior.slidingAttachment(with: self.rightItem, attachedTo: self.positionItem, attachmentAnchor: self.position, axisOfTranslation: CGVector(dx: -1.0, dy: 0.0))
	
	let position: CGPoint
	private let offset = CGFloat(15.0)
	init(position: CGPoint) {
		self.position = position
		super.init()
		positionItem.center = position
		topItem.center = CGPoint(x: position.x, y: position.y - offset)
		bottomItem.center = CGPoint(x: position.x, y: position.y + offset)
		topItem.center = CGPoint(x: position.x - offset, y: position.y)
		topItem.center = CGPoint(x: position.x + offset, y: position.y)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func attach(_ view: UIView, animator: UIDynamicAnimator) {
		view.addLayoutGuide(self)
//		topItem.constraint = self.topAnchor.constraint(equalTo: view.topAnchor)
		bottomItem.constraint = self.bottomAnchor.constraint(equalTo: view.topAnchor)
		leftItem.constraint = self.leftAnchor.constraint(equalTo: view.leftAnchor)
		rightItem.constraint = self.rightAnchor.constraint(equalTo: view.leftAnchor)

		animator.addBehavior(itemBehavior)
		animator.addBehavior(anchoredItemBehavior)
		let viewBounds = view.bounds
		topSlider.attachmentRange = UIFloatRange(minimum: 0.0, maximum: position.y - viewBounds.minY - offset)
		animator.addBehavior(topSlider)
		bottomSlider.attachmentRange = UIFloatRange(minimum: 0.0, maximum: viewBounds.maxY - position.y - offset)
		animator.addBehavior(bottomSlider)
		leftSlider.attachmentRange = UIFloatRange(minimum: 0.0, maximum: position.x - viewBounds.minX - offset)
		animator.addBehavior(leftSlider)
		rightSlider.attachmentRange = UIFloatRange(minimum: 0.0, maximum: viewBounds.maxX - position.x - offset)
		animator.addBehavior(rightSlider)
	}
	
	func addFieldBehavior(_ behavior: UIFieldBehavior) {
		behavior.addItem(topItem)
		behavior.addItem(bottomItem)
		behavior.addItem(leftItem)
		behavior.addItem(rightItem)
	}


}
