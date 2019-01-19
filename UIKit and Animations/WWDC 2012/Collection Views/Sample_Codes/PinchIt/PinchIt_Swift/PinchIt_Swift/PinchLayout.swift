//
//  PinchLayout.swift
//  PinchIt_Swift
//
//  Created by Seyed Samad Gholamzadeh on 5/19/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

class PinchLayout: UICollectionViewFlowLayout {

	var pinchedCellScale: CGFloat! {
		didSet {
			self.invalidateLayout()
		}
	}
	
	var pinchedCellCenter: CGPoint! {
		didSet {
			self.invalidateLayout()
		}
	}
	
	var pinchedCellPath: IndexPath!
	
	func applyPinchToLayoutAttributes(_ layoutAttributes: UICollectionViewLayoutAttributes) {
		
		if layoutAttributes.indexPath == self.pinchedCellPath {
			layoutAttributes.transform3D = CATransform3DMakeScale(self.pinchedCellScale, self.pinchedCellScale, 1.0)
			layoutAttributes.center = self.pinchedCellCenter
			layoutAttributes.zIndex = 1
		}
	}
	
	override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
		guard let allAttributesInRect = super.layoutAttributesForElements(in: rect) else { return nil }
		
		for cellAttributes in allAttributesInRect {
			self.applyPinchToLayoutAttributes(cellAttributes)
		}
		
		return allAttributesInRect
	}
	
	override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
		guard let attributes = super.layoutAttributesForItem(at: indexPath) else { return nil }
		self.applyPinchToLayoutAttributes(attributes)
		return attributes
	}
	
}
