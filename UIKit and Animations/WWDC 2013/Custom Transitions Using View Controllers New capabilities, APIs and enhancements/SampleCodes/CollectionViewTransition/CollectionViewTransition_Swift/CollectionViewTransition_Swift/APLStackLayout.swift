//
//  APLStackLayout.swift
//  CollectionViewTransition_Swift
//
//  Created by Seyed Samad Gholamzadeh on 6/29/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.

// Abstract: Custom collection view layout to stack collection view cells.


import UIKit

class APLStackLayout: UICollectionViewLayout {

	var stackCount: Int
	var itemSize: CGSize
	var angles: [CGFloat]
	var attributesArray: [UICollectionViewLayoutAttributes]!

	override init() {
		self.stackCount = 5
		self.itemSize = CGSize(width:150.0, height: 200.0)
		self.angles = []
		super.init()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func prepare() {
		// Compute the angles for each photo in the stack layout
		//
		// Keep in mind we only display one section in this layout.
		//
		// We use rand() to generate the varying angles, but with always the same seed value
		// so we have consistent angles when calling this method.
		//
		
		let size = self.collectionView!.bounds.size
		let center = CGPoint(x: size.width / 2.0, y: size.height / 2.0)
		
		// we only display one section in this layout
		let itemCount = self.collectionView!.numberOfItems(inSection: 0)
		
		// remove all the old attributes
//		self.angles.removeAll()

		if self.angles.isEmpty {
			let maxAngleValue: CGFloat = .pi/30
			let maxAngle = maxAngleValue
			let minAngle = -maxAngleValue
			let diff = maxAngle - minAngle
			
			// compute and add the necessary angles for each photo
			self.angles.append(0.0)
			
			for _ in 1..<self.stackCount*10 {
				let maxRand: CGFloat = CGFloat(self.stackCount*10)
				let someRand: CGFloat = CGFloat(arc4random_uniform(UInt32(maxRand)))/maxRand
				let currentAngle = (someRand*diff) + minAngle
				self.angles.append(currentAngle)
			}
		}

		if self.attributesArray == nil {
			attributesArray = []
			
			// generate the new attributes array for each photo in the stack
			for i in 0..<itemCount {
				let j = (itemCount-1)-i
				let angleIndex = i%(self.stackCount*10)
				let angle = (self.angles[angleIndex])
				
				let attributes = UICollectionViewLayoutAttributes(forCellWith: IndexPath(item: i, section: 0))
				attributes.size = self.itemSize
				attributes.center = center
				attributes.transform = CGAffineTransform(rotationAngle: angle)
				
				if i > self.stackCount {
					attributes.alpha = 0.0
				}
				else {
					attributes.alpha = 1.0
				}
				
				attributes.zIndex = j
				self.attributesArray.append(attributes)
			}
		}


	}
	
	override func invalidateLayout() {
		super.invalidateLayout()
		self.attributesArray = nil
	}
	
	override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
		let bounds = self.collectionView!.bounds
		return newBounds.width != bounds.width || newBounds.height != bounds.height
	}
	
	override var collectionViewContentSize: CGSize {
		return self.collectionView!.bounds.size
	}
	
	override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
		return self.attributesArray[indexPath.item]
	}
	
	override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
		return self.attributesArray
	}
	
}
