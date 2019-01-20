//
//  SVScrollingCell.swift
//  iOS7ScrollViews_Siwft
//
//  Created by Seyed Samad Gholamzadeh on 7/7/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

protocol SVScrollingCellDelegate: class {
	func scrollingCellDidBeginPulling(_ cell: SVScrollingCell)
	func scrolling(_ cell: SVScrollingCell, didChangePullOffset offset: CGFloat)
	func scrollingCellDidEndPulling(_ cell: SVScrollingCell)
}

class SVScrollingCell: UICollectionViewCell, UIScrollViewDelegate {
	let PULL_THRESHOLD: CGFloat = 120
	
	var delegate: SVScrollingCellDelegate!
	
	var color: UIColor! {
		didSet {
			colorView.backgroundColor = color
		}
	}
	
	var scrollView: UIScrollView!
	var colorView: UIView!
	var isPulling: Bool = false
	var deceleratingBackToZero: Bool = false
	var decelerationDistanceRatio: CGFloat!

	//MARK: - UIScrollViewDelegate
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		let offset = scrollView.contentOffset.x
		
		if offset > PULL_THRESHOLD, !isPulling {
			self.delegate.scrollingCellDidBeginPulling(self)
			self.isPulling = true
		}
		
		if self.isPulling {
			var pullOffset: CGFloat!
			
			if self.deceleratingBackToZero {
				pullOffset = offset * decelerationDistanceRatio
			}
			else {
				pullOffset = max(0, offset - PULL_THRESHOLD)
			}
			
			self.delegate.scrolling(self, didChangePullOffset: pullOffset)
			self.scrollView.transform = CGAffineTransform(translationX: pullOffset, y: 0)
		}
	}
	
	func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
		if !decelerate {
			self.scrollingEnded()
		}
	}
	
	func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
		self.scrollingEnded()
	}
	
	func scrollingEnded() {
		self.delegate.scrollingCellDidEndPulling(self)
		self.isPulling = false
		self.deceleratingBackToZero = false
		
		self.scrollView.contentOffset = CGPoint.zero
		self.scrollView.transform = CGAffineTransform.identity
	}
	
	func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
		// Not working on iOS6
		// This method is not called when the value of the scroll view’s pagingEnabled property is YES.
		let offset = self.scrollView.contentOffset.x
		
		if targetContentOffset.pointee.x == 0, offset > 0 {
			self.deceleratingBackToZero = true
			
			let pullOffset = max(0, offset - PULL_THRESHOLD)
			self.decelerationDistanceRatio  = pullOffset/offset
		}
	}
	
	//MARK: - Setup & Layout
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		self.colorView = UIView()
		self.colorView.backgroundColor = .yellow
		self.scrollView = UIScrollView()
		self.scrollView.delegate = self
		self.scrollView.isPagingEnabled = true
		self.scrollView.showsHorizontalScrollIndicator = false
		
		self.contentView.addSubview(self.scrollView)
		self.scrollView.addSubview(self.colorView)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		let contentView = self.contentView
		let bounds = self.contentView.bounds
		let pageWidth = bounds.size.width + PULL_THRESHOLD
		
		self.scrollView.frame = CGRect(x: 0, y: 0, width: pageWidth, height: bounds.size.height)
		self.scrollView.contentSize = CGSize(width: pageWidth*2, height: bounds.size.height)
		
		self.colorView.frame = self.scrollView.convert(bounds, from: contentView)
	}
}
