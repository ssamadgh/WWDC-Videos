//
//  CoverFlowLayout.swift
//  CoverFlowLayout
//
//  Created by Broccoli on 15/11/26.
//  Copyright © 2015年 Broccoli. All rights reserved.
//

import UIKit

class CoverFlowLayout: UICollectionViewFlowLayout {
    let kDistanceToProjectionPlane: CGFloat = 500.0
    
    var maxCoverDegree: CGFloat = 30.0
    var coverDensity: CGFloat = 0.25
	
	override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }

	override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
		let indexPaths = indexPathsOfItemsInRect(rect: rect)
        
        var resultingAttributes = [UICollectionViewLayoutAttributes]()
        
        for indexPath in indexPaths {
			let attributes = layoutAttributesForItem(at: indexPath as IndexPath)!
            resultingAttributes.append(attributes)
        }
        return resultingAttributes
    }
	
	override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
		let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        
        attributes.size = itemSize
        attributes.center = CGPoint(x: collectionView!.bounds.size.width * CGFloat(indexPath.row) + collectionView!.bounds.size.width, y: collectionView!.bounds.size.height / 2)
        
		interpolateAttributes(attributes: attributes, forOffset: collectionView!.contentOffset.x)
        return attributes
    }
	
	override var collectionViewContentSize: CGSize {
		return CGSize(width: collectionView!.bounds.width * CGFloat(collectionView!.numberOfItems(inSection: 0)), height: collectionView!.bounds.height)
    }
}


// MARK: - private method
private extension CoverFlowLayout {
    func indexPathsOfItemsInRect(rect: CGRect) -> [NSIndexPath] {
		if collectionView!.numberOfItems(inSection: 0) == 0 {
            return [NSIndexPath]()
        }
        var minRow: Int = max(Int(rect.origin.x / collectionView!.bounds.width), 0)
        var maxRow: Int = Int(rect.maxX / collectionView!.bounds.width)
        
        let candidateMinRow = max(minRow - 1, 0)
		if maxXForRow(row: candidateMinRow) >= rect.origin.x {
            minRow = candidateMinRow
        }
        
		let candidateMaxRow = min(maxRow + 1, collectionView!.numberOfItems(inSection: 0) - 1)
		if minXForRow(row: candidateMaxRow) <= rect.maxX {
            maxRow = candidateMaxRow
        }
        
        var resultingInexPaths = [NSIndexPath]()
        
        for i in Int(minRow) ..< Int(maxRow) + 1 {
            resultingInexPaths.append(NSIndexPath(row: i, section: 0))
        }
        
        return resultingInexPaths
    }

    func minXForRow(row: Int) -> CGFloat {
		return itemCenterForRow(row: row - 1).x + (1 / 2 - coverDensity) * itemSize.width
    }
    
    func maxXForRow(row: Int) -> CGFloat {
		return itemCenterForRow(row: row + 1).x - (1 / 2 - coverDensity) * itemSize.width
    }
    
    func minXCenterForRow(row: Int) -> CGFloat {
        let halfWidth = itemSize.width / 2
        let maxRads = maxCoverDegree * CGFloat.pi / 180
		let center = itemCenterForRow(row: row - 1).x
        let prevItemRightEdge = center + halfWidth
        let projectedLeftEdgeLocal = halfWidth * cos(maxRads) * kDistanceToProjectionPlane / (kDistanceToProjectionPlane + halfWidth * sin(maxRads))
        return prevItemRightEdge - coverDensity * itemSize.width + projectedLeftEdgeLocal
    }
    
    func maxXCenterForRow(row: Int) -> CGFloat {
        let halfWidth = itemSize.width / 2
        let maxRads = maxCoverDegree * CGFloat.pi / 180
		let center = itemCenterForRow(row: row + 1).x
        let nextItemLeftEdge = center - halfWidth
        let projectedRightEdgeLocal = fabs(halfWidth * cos(maxRads) * kDistanceToProjectionPlane / (-halfWidth * sin(maxRads) - kDistanceToProjectionPlane))
        return nextItemLeftEdge + coverDensity * itemSize.width - projectedRightEdgeLocal
    }
    
    func itemCenterForRow(row: Int) -> CGPoint {
        let collectionViewSize = collectionView!.bounds.size
        return CGPoint(x: CGFloat(row) * collectionViewSize.width + collectionViewSize.width / 2, y: collectionViewSize.height / 2)
    }
    
    func interpolateAttributes(attributes: UICollectionViewLayoutAttributes, forOffset offset: CGFloat) {
        let attributesPath = attributes.indexPath
        
        let minInterval = CGFloat(attributesPath.row - 1) * collectionView!.bounds.width
        let maxInterval = CGFloat(attributesPath.row + 1) * collectionView!.bounds.width
        
		let minX = minXCenterForRow(row: attributesPath.row)
		let maxX = maxXCenterForRow(row: attributesPath.row)
        
        let interpolatedX = min(max(minX + (((maxX - minX) / (maxInterval - minInterval)) * (offset - minInterval)), minX), maxX)
        attributes.center = CGPoint(x: interpolatedX, y: attributes.center.y)
        
        let angle = -maxCoverDegree + (interpolatedX - minX) * 2 * maxCoverDegree / (maxX - minX)
        var transform = CATransform3DIdentity
        
        transform.m34 = -1.0 / kDistanceToProjectionPlane
        transform = CATransform3DRotate(transform, angle * CGFloat.pi / 180, 0, 1, 0)
        attributes.transform3D = transform
        attributes.zIndex = NSIntegerMax - attributesPath.row
    }
}
