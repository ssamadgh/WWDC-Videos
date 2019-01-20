//
//  SpringyFlowLayout.swift
//  iOS7ScrollViews_Siwft
//
//  Created by Seyed Samad Gholamzadeh on 7/8/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

class SpringyFlowLayout: UICollectionViewFlowLayout {

	var dynamicAnimator: UIDynamicAnimator!
	
	override func prepare() {
		super.prepare()
		
		if dynamicAnimator == nil {
			self.dynamicAnimator = UIDynamicAnimator(collectionViewLayout: self)
			
			let contentSize: CGSize = self.collectionViewContentSize
			let items = super.layoutAttributesForElements(in: CGRect(origin: .zero, size: contentSize)) ?? []
			
			for item in items {
				let spring = UIAttachmentBehavior(item: item, attachedToAnchor: item.center)
				spring.length = 0
				spring.damping = 0.5
				spring.frequency = 0.8
				
				dynamicAnimator.addBehavior(spring)
			}
		}
	}
	
	override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
		return self.dynamicAnimator.items(in: rect) as? [UICollectionViewLayoutAttributes]
	}
	
	override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
		return self.dynamicAnimator.layoutAttributesForCell(at: indexPath)
	}
	
	override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
		let scrollView: UIScrollView = self.collectionView! as UIScrollView
		let scrollData = newBounds.origin.y - scrollView.bounds.origin.y
		let touchLocation = scrollView.panGestureRecognizer.location(in: scrollView)
		
		for spring in self.dynamicAnimator.behaviors {
			let anchorPoint = (spring as! UIAttachmentBehavior).anchorPoint
			let distanceFromTouch = fabs(touchLocation.y - anchorPoint.y)
			let scrollResistance = distanceFromTouch/500
			let item = (spring as! UIAttachmentBehavior).items.first!
			var center = item.center

			if scrollData > 0 {
				center.y += min(scrollData, scrollData*scrollResistance)
			}
			else {
				center.y += max(scrollData, scrollData*scrollResistance)
			}
			
			center.y += scrollData*scrollResistance
			item.center = center
			
			self.dynamicAnimator.updateItem(usingCurrentState: item)
		}
		
		return false
	}
	
	
}
