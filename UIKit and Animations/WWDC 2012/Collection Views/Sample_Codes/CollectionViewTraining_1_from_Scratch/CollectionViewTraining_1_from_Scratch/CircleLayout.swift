//
//  LineLayout.swift
//  LineLayout_Swift
//
//  Created by Seyed Samad Gholamzadeh on 4/30/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

class CircleLayout: UICollectionViewLayout {
	
	let item_Size: CGFloat = 70

	var center: CGPoint!
	var radius: CGFloat!
	var cellCount: Int!
	var deletedIndexPaths: [IndexPath]! = []
	var insertedIndexPaths: [IndexPath]! = []
	
	override func prepare() {
		super.prepare()
		if let size = self.collectionView?.frame.size {
			cellCount = self.collectionView!.numberOfItems(inSection: 0)
			center = CGPoint(x: size.width/2, y: size.height/2)
			radius = min(size.width, size.height)/2.5
		}
	}
	
	override var collectionViewContentSize: CGSize {
		return self.collectionView!.frame.size
	}
	
	override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
		let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
		attributes.size = CGSize(width: item_Size, height: item_Size)
		attributes.center = CGPoint(x: center.x + radius * cos(2 * CGFloat(indexPath.item) * .pi / CGFloat(cellCount)), y: center.y + radius * sin(2 * CGFloat(indexPath.item) * .pi / CGFloat(cellCount)))
		return attributes
	}
	
	override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
		var attributes: [UICollectionViewLayoutAttributes] = []

		for i in 0..<self.cellCount {
			let indexPath = IndexPath(item: i, section: 0)
			attributes.append(self.layoutAttributesForItem(at: indexPath)!)
		}
		return attributes
	}
	
	
	override func prepare(forCollectionViewUpdates updateItems: [UICollectionViewUpdateItem]) {
		
		// Keep track of insert and delete index paths
		super.prepare(forCollectionViewUpdates: updateItems)
		
		self.deletedIndexPaths = []
		self.insertedIndexPaths = []
		
		for update in updateItems {
			if update.updateAction == .delete {
				self.deletedIndexPaths.append(update.indexPathBeforeUpdate!)
			}
			else if update.updateAction == .insert {
				self.insertedIndexPaths.append(update.indexPathAfterUpdate!)
			}
		}
	}
	
	override func finalizeCollectionViewUpdates() {
		super.finalizeCollectionViewUpdates()
		
		// release the insert and delete index paths
		self.deletedIndexPaths = []
		self.insertedIndexPaths = []
	}
	
	// Note: name of method changed
	// Also this gets called for all visible cells (not just the inserted ones) and
	// even gets called when deleting cells!
	override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
		
		// Must call super
		var attributes = super.initialLayoutAttributesForAppearingItem(at: itemIndexPath)
		
		if self.insertedIndexPaths.contains(itemIndexPath) {
			// only change attributes on inserted cells
			if attributes == nil {
				attributes = self.layoutAttributesForItem(at: itemIndexPath)
			}
			
			// Configure attributes ...
			attributes!.alpha = 0.0
			attributes!.center = center
			attributes!.transform3D = CATransform3DMakeScale(0.1, 0.1, 1.0)

		}
		
		return attributes
	}

	// Note: name of method changed
	// Also this gets called for all visible cells (not just the deleted ones) and
	// even gets called when inserting cells!
	override func finalLayoutAttributesForDisappearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
		
		// So far, calling super hasn't been strictly necessary here, but leaving it in
		// for good measure
		var attributes = super.finalLayoutAttributesForDisappearingItem(at: itemIndexPath)
		
		if self.deletedIndexPaths.contains(itemIndexPath) {
			
			// only change attributes on deleted cells
			if attributes == nil {
				attributes = self.layoutAttributesForItem(at: itemIndexPath)
			}
			
			// Configure attributes ...
			attributes!.alpha = 0.0
			attributes!.center = center
			attributes!.transform3D = CATransform3DMakeScale(0.1, 0.1, 1.0)
		}
		
		return attributes
	}

}
