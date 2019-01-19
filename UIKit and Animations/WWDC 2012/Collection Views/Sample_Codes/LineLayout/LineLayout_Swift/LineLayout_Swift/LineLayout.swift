//
//  LineLayout.swift
//  LineLayout_Swift
//
//  Created by Seyed Samad Gholamzadeh on 4/30/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

class LineLayout: UICollectionViewFlowLayout {

	let item_Size: CGFloat = 250.0
	let active_Distance: CGFloat = 150.0
	let zoom_Factor: CGFloat = 0.3
	
	override init() {
		super.init()
		self.itemSize = CGSize(width: item_Size, height: item_Size)
		self.scrollDirection = .horizontal
		self.sectionInset = UIEdgeInsets(top: 150, left: 0, bottom: 150, right: 10)
		self.minimumLineSpacing = 50
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
		return true
	}


	override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {

		guard let array = super.layoutAttributesForElements(in: rect) else { return nil }
		let origin = self.collectionView?.contentOffset ?? CGPoint.zero
		let size = self.collectionView?.bounds.size ?? CGSize.zero
		let visibleRect: CGRect = CGRect(origin: origin, size: size)

		for attributes in array {

			if attributes.frame.intersects(rect) {
				let distance = visibleRect.midX - attributes.center.x
				let normalizedDistance = distance/active_Distance
				if abs(distance) < active_Distance {
					let zoom: CGFloat = 1 + zoom_Factor*(1 - abs(normalizedDistance))
					attributes.transform3D = CATransform3DMakeScale(zoom, zoom, 1.0)
					var transform = CATransform3DMakeScale(zoom, zoom, 1.0)
					transform.m34 = -1.0 / 500.0
//					transform = CATransform3DRotate(transform, normalizedDistance * CGFloat.pi, 0, 0, 1)
//					attributes.transform3D = CATransform3DInvert(transform)
					attributes.zIndex = 1
				}
			}
		}

		return array
	}

	override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {

		var offsetAdjustment: CGFloat = CGFloat.greatestFiniteMagnitude
//		print("offsetAdjustment ," , abs(offsetAdjustment) )
		let width = self.collectionView?.bounds.width ?? 0
		let height = self.collectionView?.bounds.height ?? 0

		let horizontalCenter = proposedContentOffset.x + width/2.0

		let targetRect = CGRect(x: proposedContentOffset.x, y: 0.0, width: width, height: height)
		guard let array = super.layoutAttributesForElements(in: targetRect) else { return CGPoint.zero }

		for layoutAttributes in array {
			let itemHorizontalCenter = layoutAttributes.center.x
//			print("abs(itemHorizontalCenter - horizontalCenter) ," , abs(itemHorizontalCenter - horizontalCenter))

			if abs(itemHorizontalCenter - horizontalCenter) < abs(offsetAdjustment) {
				offsetAdjustment = itemHorizontalCenter - horizontalCenter
			}
		}

		return CGPoint(x: proposedContentOffset.x + offsetAdjustment, y: proposedContentOffset.y)
	}
}
