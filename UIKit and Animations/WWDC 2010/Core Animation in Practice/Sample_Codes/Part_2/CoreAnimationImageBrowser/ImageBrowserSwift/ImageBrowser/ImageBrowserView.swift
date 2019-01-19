//
//  ImageBrowserView.swift
//  ImageBrowser
//
//  Created by Seyed Samad Gholamzadeh on 2/2/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

class ImageBrowserView: UIScrollView, UIScrollViewDelegate {
	
	var recycledViews: Set<ImageBrowserItemView> = []
	var visibleViews: Set<ImageBrowserItemView> = []
	
	struct Item {
		static let border: CGFloat = 20
		static let spacing: CGFloat = 20
		static let width: CGFloat = 300
		static let height: CGFloat = 255
	}
	
	
	var imageURLs: [URL]! {
		didSet {
			if useTiling {
				self.delegate = self
				self.contentSize = self.contentSize(for: self.imageURLs.count)
				self.tileViews()
			}
			else {
				
				if oldValue != nil {
					if self.imageURLs != oldValue {
						self.setNeedsLayout()
					}
				}
				else {
					self.setNeedsLayout()
				}
				
			}
			
		}
	}
	
	
	weak var controller: ImageBrowserViewController!
	var itemViews: [ImageBrowserItemView] = []
	var lastWidth: CGFloat!
	var itemSize: CGSize!
	var softEdgeLayer: ImageBrowserSoftEdgeLayer!
	var isOldView = false
	
	
	override func layoutSubviews() {
		
		defer {
			if softScrollerEdges != 0 {
				if softEdgeLayer == nil {
					softEdgeLayer = ImageBrowserSoftEdgeLayer()
				}
				
				CATransaction.begin()
				CATransaction.setDisableActions(true)
				
				if softScrollerEdges == 1 {
					self.layer.mask = self.softEdgeLayer
				}
				else {
					self.layer.addSublayer(self.softEdgeLayer)
				}
				
				self.softEdgeLayer.frame = self.bounds
				
				CATransaction.commit()
			}
		}

		
		guard !useTiling else {
			return
		}
		var itemCount, oldViewCount : Int
		var url: URL!
		var view: ImageBrowserItemView!
		var oldViews: [ImageBrowserItemView]!
		var x, y: CGFloat
		var bounds, frame: CGRect!
		
		itemCount = imageURLs.count
		oldViews = itemViews
		itemViews = []
		oldViewCount = oldViews.count
		bounds = self.bounds
		
		if lastWidth != bounds.size.width {
			lastWidth = bounds.size.width
			itemSize = CGSize(width: Item.width, height: Item.height)
		}
		
		x = Item.border
		y = Item.border
		
		isOldView = false
		for i in 0..<itemCount {
			frame = CGRect(x: x, y: y, width: itemSize.width, height: itemSize.height)
			url = imageURLs[i]
			
			for j in 0..<oldViewCount {
				
				view = oldViews[j]
				if view.imageURL == url {
					view.frame = frame
					oldViews.remove(at: j)
					oldViewCount -= 1
					isOldView = true
					itemViews.append(view)
					break
				}
			}
			
			
			if !isOldView {
				view = ImageBrowserItemView.itemViewWith(frame, imageURL: url)
				view.isOpaque = isOpaqueItemViews
				self.addSubview(view)
				itemViews.append(view)
			}
			
			
			x += itemSize.width + Item.spacing
			if x + itemSize.width + Item.border > bounds.size.width {
				x = Item.border
				y += itemSize.height + Item.spacing
			}
		}
		
		if x > Item.border {
			y += itemSize.height + Item.border
		}
		
		self.contentSize = CGSize(width: bounds.size.width, height: y)
		
		for view in oldViews {
			view.removeFromSuperview()
		}
		oldViews = []
		
	}
	
	func tileViews() {
		
		var firstNeededViewIndex: Int = self.firstNeededViewIndex
		var lastNeededViewIndex: Int = self.lastNeededViewIndex
		
		firstNeededViewIndex = max(firstNeededViewIndex, 0)
		lastNeededViewIndex = min(lastNeededViewIndex, self.imageURLs.count - 1)
		
		//Recycle no longer needs views
//		for view in self.visibleViews {
//			if view.index < firstNeededViewIndex || view.index > lastNeededViewIndex {
//				self.recycledViews.insert(view)
//				view.removeFromSuperview()
//			}
//		}
//
//		self.visibleViews.subtract(self.recycledViews)
		
		//add missing pages
		for index in firstNeededViewIndex...lastNeededViewIndex {
			if !self.isDisplayingView(forIndex: index) {
				
				let url = imageURLs[index]
				let view = self.dequeueRecycledView() ?? ImageBrowserItemView.itemViewWith(self.frameForPage(at: index), imageURL: url)
				self.configure(view, for: index)
				self.visibleViews.insert(view)
			}
		}
	}
	
	
	func dequeueRecycledView() -> ImageBrowserItemView? {
		if let view = self.recycledViews.first {
			self.recycledViews.removeFirst()
			return view
		}
		return nil
	}
	
	
	func isDisplayingView(forIndex index: Int) -> Bool {
		for view in self.visibleViews {
			if view.index == index {
				return true
			}
		}
		return false
	}
	
	func configure(_ view: ImageBrowserItemView, for index: Int) {
		let url = imageURLs[index]
		view.itemLayer.imageURL = url
		view.index = index
		view.frame = self.frameForPage(at: index)
		self.addSubview(view)
	}
	
	
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		DispatchQueue.main.async {
			self.tileViews()
		}
	}
	
	func contentSize(for count: Int) -> CGSize {
		let contentWidth = self.bounds.width
		let columns = self.visibleColumns
		
		//		let rows = Int(ceil(CGFloat(count/columns)))
		let rows = count%columns == 0 ? count/columns : count/columns + 1
		
		
		let contentHeight = Item.border*2 + CGFloat(rows)*(Item.height) + CGFloat(rows - 1)*(Item.spacing)
		
		let contentSize: CGSize = CGSize(width: contentWidth, height: contentHeight)
		
		return contentSize
	}
	
	lazy var visibleColumns: Int = {
		let visibleWidth = self.bounds.width
		var columns = 0
		var sWidth = Item.border
		
		while sWidth + Item.border < visibleWidth {
			sWidth += Item.width + Item.spacing
			columns += 1
		}
		return columns
	}()
	
	var firstNeededRow: Int {
		let minVisibleX: CGFloat = self.bounds.minY
		
		var rows = 0
		var sHeihgt = Item.border
		
		while sHeihgt + Item.border < minVisibleX {
			sHeihgt += Item.height + Item.spacing
			rows += 1
		}
		return rows
	}
	
	var lastNeededRow: Int {
		let maxVisibleX: CGFloat = self.bounds.maxY
		
		var rows = 0
		var sHeihgt = Item.border
		
		while sHeihgt + Item.border < maxVisibleX {
			sHeihgt += Item.height + Item.spacing
			rows += 1
		}
		return rows
	}
	
	
	var firstNeededViewIndex: Int {
		let previousViewsCount = (self.firstNeededRow - 1)*visibleColumns
		return previousViewsCount
	}
	
	var lastNeededViewIndex: Int {
		let previousViewsCount = (self.lastNeededRow + 1)*visibleColumns
		return previousViewsCount
	}
	
	func originFor(index: Int) -> CGPoint {
		let row = Int(floor(CGFloat(index/self.visibleColumns)))
		
		let y: CGFloat = Item.border + CGFloat(row)*(Item.height + Item.spacing)
		
		let diff = index - row*self.visibleColumns
		let column = diff == 0 ? self.visibleColumns : diff
		
		let x = Item.border + CGFloat(column - 1)*(Item.width + Item.spacing)
		
		return CGPoint(x: x, y: y)
	}
	
	func frameForPage(at index: Int) -> CGRect {
		let origin = self.originFor(index: index)
		let frame = CGRect(x: origin.x, y: origin.y, width: Item.width, height: Item.height)
		return frame
	}
}
