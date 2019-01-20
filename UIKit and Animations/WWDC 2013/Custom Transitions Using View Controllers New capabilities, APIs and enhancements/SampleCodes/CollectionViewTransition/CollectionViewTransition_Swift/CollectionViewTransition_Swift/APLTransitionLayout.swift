//
//  APLTransitionLayout.swift
//  CollectionViewTransition_Swift
//
//  Created by Seyed Samad Gholamzadeh on 6/30/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

class APLTransitionLayout: UICollectionViewTransitionLayout {

	let kOffsetH = "offsetH"
	let kOffsetV = "offsetV"

	
	// called by the APLTransitionManager class while updating its transition progress, animating
	// the collection view items in an out of stack mode.
	//
	var offset: UIOffset! {
		didSet {
			// store the floating-point values with out meaningful keys for our transition layout object
			self.updateValue(offset.horizontal, forAnimatedKey: kOffsetH)
			self.updateValue(offset.vertical, forAnimatedKey: kOffsetV)
		}
	}
	
	// set the completion progress of the current transition.
	//
	override var transitionProgress: CGFloat {
		didSet {
			super.transitionProgress = transitionProgress
			
			// return the most recently set values for each key
			let offsetH = self.value(forAnimatedKey: kOffsetH)
			let offsetV = self.value(forAnimatedKey: kOffsetV)
			self.offset = UIOffset(horizontal: offsetH, vertical: offsetV)
		}
	}
	
	override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
		guard let attributes = super.layoutAttributesForElements(in: rect) else { return nil }
		
		for currentAttribute in attributes {
			let currentCenter = currentAttribute.center
			let updatedCenter = CGPoint(x: currentCenter.x + self.offset.horizontal, y: currentCenter.y + self.offset.vertical)
			currentAttribute.center = updatedCenter
		}
		
		let itemCount = self.collectionView!.numberOfItems(inSection: 0)
		for item in 0..<itemCount {
			let indexPath = IndexPath(item: item, section: 0)
			if let attributes = self.layoutAttributesForItem(at: indexPath) {
				attributes.zIndex = (itemCount - 1) - item
			}
		}
		
		return attributes
	}
	
	override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
		// returns the layout attributes for the item at the specified index path
		guard let attributes = super.layoutAttributesForItem(at: indexPath) else { return nil }
		let currentCenter = attributes.center
		let updateCenter = CGPoint(x: currentCenter.x + self.offset.horizontal, y: currentCenter.y + self.offset.vertical)
		attributes.center = updateCenter
		let itemCount = self.collectionView!.numberOfItems(inSection: 0)
		attributes.zIndex = (itemCount - 1) - indexPath.item
		return attributes
	}
	
}
