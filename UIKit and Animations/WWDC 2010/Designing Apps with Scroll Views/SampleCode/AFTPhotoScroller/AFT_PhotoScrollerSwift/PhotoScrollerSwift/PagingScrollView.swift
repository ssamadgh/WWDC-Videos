//
//  PagingScrollView.swift
//  PhotoScrollerSwift
//
//  Created by Seyed Samad Gholamzadeh on 10/8/1396 AP.
//  Copyright © 1396 AP Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

enum PagingScrollViewNavigationOrientation: Int {
	case horizontal = 0
	case vertical = 1
}

protocol PagingScrollViewDataSource {
	/**
	Ask the data source to return the number of pages in the paging scroll view.
	*/
	func numberOfPages(in pagingScrollView: PagingScrollView) -> Int
	
	/**
	Ask the data source to return the image for specific page index in the paging scroll view.
	@warning The returned image object must be not nil.
	*/
	func pagingScrollView(_ pagingScrollView: PagingScrollView, imageForPageAtIndex pageIndex: Int) -> UIImage
	
	
}

protocol PagingScrollViewDelegate {
	/**
	Ask the delegate if the specified page should be displayed on screen. Default is true.
	@warning This method will be called when the specified page is about to show on screen, and it will be called multiple times when user scrolling and constantly checking the result. For performance reason, try not to implement this method heavily.
	*/
	func pagingScrollView(_ pagingScrollView: PagingScrollView, shouldDisplayPageAtIndex pageIndex: Int) -> Bool
	
	/**
	Tells the delegate that when the paging view is about to start scrolling the pages.
	*/
	func pagingScrollViewWillBeginPaging(_ pagingScrollView: PagingScrollView)
	
	/**
	Tells the delegate that a specified page is taken more than half of pagingScrollView's size during page-scrolling.
	*/
	func pagingScrollView(_ pagingScrollView: PagingScrollView, didScrollToPageAtIndex pageIndex: Int)
	
	/**
	Tells the delegate that a specified page is finally displayed on screen after page-scrolling or -displayPageAtIndex: method is called.
	*/
	func pagingScrollView(_ pagingScrollView: PagingScrollView, didDisplayPageAtIndex pageIndex: Int)
	
	/**
	Tells the delegate that when the paging view is about to start zooming the image. (即将放大或缩小图片)
	@param imageScrollView The inner scroll view which handles the image zooming.
	*/
	func pagingScrollView(_ pagingScrollView: PagingScrollView, willBeginZooming imageScrollView: UIScrollView, atPageIndex pageIndex: Int)
	
	/**
	Tells the delegate that when user scrolls a scaled image for the specified page.
	@param imageScrollView The inner scroll view which handles the image zooming.
	*/
	func pagingScrollView(_ pagingScrollView: PagingScrollView, didScrollImageScrollView:UIScrollView, atPageIndex pageIndex: Int)
	
	/**
	Tells the delegate that when the imageScrollView enables a double-tap-to-zoom gesture for its imageView. Using this callback method for additional setup, e.g. [singleTap requireGestureRecognizerToFail:zoomingTap]
	
	@param imageScrollView The inner scroll view which handles the image zooming.
	@param zoomingTap A double tap gesture for handle image zooming.
	*/
	func pagingScrollView(_ pagingScrollView: PagingScrollView, didEnableZoomingTapGesture zoomingTap: UITapGestureRecognizer, forImageScrollView imageScrollView: UIScrollView)
	
	/**
	Tells the delegate that when a double tap to zoom image gesture is recognized.
	
	@param imageScrollView The inner scroll view which handles the image zooming.
	@param zoomingTap A double tap gesture for handle image zooming.
	*/
	func pagingScrollView(_ pagingScrollView: PagingScrollView, didRecognizeZoomingTapGesture zoomingTap: UITapGestureRecognizer, forImageScrollView imageScrollView: UIScrollView)
	
	/**
	Tells the delegate that when the imageScrollView is recycled for the specified page.
	@param imageScrollView The inner scroll view which handles the image zooming.
	*/
	func pagingScrollView(_ pagingScrollView: PagingScrollView, didRecycleImageScrollView imageScrollView: UIScrollView, forPageIndex pageIndex: Int)
	
	/**
	Tells the delegate that when the imageScrollView is reused for the specified page.
	@param imageScrollView The inner scroll view which handles the image zooming.
	*/
	func pagingScrollView(_ pagingScrollView: PagingScrollView, didReuseImageScrollView imageScrollView: UIScrollView, forPageIndex pageIndex: Int)
}

extension PagingScrollViewDelegate {
	func pagingScrollView(_ pagingScrollView: PagingScrollView, shouldDisplayPageAtIndex pageIndex: Int) -> Bool {
		return true
	}
	
	func pagingScrollViewWillBeginPaging(_ pagingScrollView: PagingScrollView) { }
	
	func pagingScrollView(_ pagingScrollView: PagingScrollView, didScrollToPageAtIndex pageIndex: Int) { }
	
	func pagingScrollView(_ pagingScrollView: PagingScrollView, didDisplayPageAtIndex pageIndex: Int) { }
	
	func pagingScrollView(_ pagingScrollView: PagingScrollView, willBeginZooming imageScrollView: UIScrollView, atPageIndex pageIndex: Int) { }
	
	func pagingScrollView(_ pagingScrollView: PagingScrollView, didScrollImageScrollView:UIScrollView, atPageIndex pageIndex: Int) { }
	
	func pagingScrollView(_ pagingScrollView: PagingScrollView, didEnableZoomingTapGesture zoomingTap: UITapGestureRecognizer, forImageScrollView imageScrollView: UIScrollView) { }
	
	func pagingScrollView(_ pagingScrollView: PagingScrollView, didRecognizeZoomingTapGesture zoomingTap: UITapGestureRecognizer, forImageScrollView imageScrollView: UIScrollView) { }
	
	func pagingScrollView(_ pagingScrollView: PagingScrollView, didRecycleImageScrollView imageScrollView: UIScrollView, forPageIndex pageIndex: Int) { }
	
	func pagingScrollView(_ pagingScrollView: PagingScrollView, didReuseImageScrollView imageScrollView: UIScrollView, forPageIndex pageIndex: Int) { }
}

private let PAGING_DEBUG = 0
private let PAGING_IMAGE_CACHE_LOG = 0

@IBDesignable class PagingScrollView: UIView, UIScrollViewDelegate {

	var delegate: PagingScrollViewDelegate?
	var dataSource: PagingScrollViewDataSource?
	
	override var backgroundColor: UIColor? {
		didSet {
			if self.backgroundColor != nil {
				self.updateBackgroundColor(to: self.backgroundColor!)
			}
		}
	}
	
	/**
	The direction for page scrolling. The default value is horizontal.
	*/
	var _navigationOrientation: PagingScrollViewNavigationOrientation = .horizontal
	
	@IBInspectable var navigationOrientation: Int {
		return _navigationOrientation.rawValue
	}

	/**
	The horizontal padding between pages. The default value is 0.
	@note If parallaxScrollingEnabled is YES, then the default padding is 20.
	*/
	@IBInspectable var paddingBetweenPages: CGFloat {
		get {
			return isParallaxScrollingEnabled ? parallaxPagePadding : pagePadding
		}
		
		set {
			pagePadding = newValue
		}
	}
	
	/**
	A floating-point value that specifies the maximum scale factor that can be applied to the image. The default value is 1.0
	*/
	var maximumImageZoomScale: CGFloat!
	
	/**
	Whether require a double tap gesture with single touch for zooming image. The default value is YES.
	*/
	var isZoomingTapEnabled: Bool!
	
	@IBInspectable var zoomingTapEnabled: Bool {
		return isZoomingTapEnabled
	}
	/**
	The floating-point value for specifying how much to stretch image by using zooming tap gesture. The value range is from 0 to 1 and default value is 1, which means scaling image to maximum zoom scale. This property only works when zoomingTapEnabled is YES.
	*/
	var zoomingTapProgress: CGFloat {
		get {
			return _zoomingTapProgress
		}
		set {
			if newValue <= 0 || newValue > 1 {
				_zoomingTapProgress = 1
			}
			else {
				_zoomingTapProgress = newValue
			}
		}
	}
	
	/**
	Whether applying parallax scrolling effect for page scrolling just like Photo app in iOS 10. The default value is NO.
	@note If YES, the default parallax padding is 20.0f, which can be modified by paddingBetweenPages property.
	*/
	var isParallaxScrollingEnabled: Bool = false
	@IBInspectable var parallaxScrollingEnabled: Bool {
		return isParallaxScrollingEnabled
	}

	/**
	The current index of pages.
	@note This value will change immediately after user scrolls across half of page.
	*/
	var currentPageIndex: Int!
	
	/**
	The total number of pages.
	*/
	var numberOfPages: Int {
		return pageCount
	}
	
	var isHorizontalDirection: Bool {
		return _navigationOrientation == .horizontal
	}
	
	var isVerticalDirection: Bool {
		return _navigationOrientation == .vertical
	}
	
	var pagingScrollView: UIScrollView!
	var parallaxSeparator: UIView!
	var recycledPages: Set<TImageScrollView>!
	var visiblePages: Set<TImageScrollView>!
	var nextPageIndex: Int!
	var imageCache: [Int: UIImage]!
	
	private var _zoomingTapProgress: CGFloat!
	private var pageCount: Int!
	
	private var pagePadding: CGFloat = 0
	private var parallaxPagePadding: CGFloat = 0
	
	private var lastContentOffset: CGPoint!
	private var firstTimeLoadPage: Bool!
	
	private var firstVisiblePageIndexBeforeRotation: Int!
	private var percentScrolledIntoFirstVisiblePage: CGFloat!

	//MARK: - Life cycle
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.setup()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func setup() {
		self.recycledPages = []
		self.visiblePages  = []
		self.imageCache = [:]
		
		self.firstTimeLoadPage = true
		self.lastContentOffset = CGPoint.zero
		
		self.maximumImageZoomScale = 1.0
		self.isZoomingTapEnabled = true
		self.zoomingTapProgress = 1.0
		
		NotificationCenter.default.addObserver(self, selector: #selector(PagingScrollView.removeImageCache), name: NSNotification.Name.UIApplicationDidReceiveMemoryWarning, object: UIApplication.shared)
		
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		// Fix bugs for loading from interface builder (UIStoryboard)
		// ----------------------------------------------------------
		if isParallaxScrollingEnabled {
			var parallaxSeparatorFrame = self.parallaxSeparator!.frame
			parallaxSeparatorFrame.size = self.sizeForParallaxSeparator()
			self.parallaxSeparator.frame = parallaxSeparatorFrame
		}
		self.saveCurrentStatesForRotation()
		self.restoreStatesForRotation()
		// ----------------------------------------------------------
	}
	
	//MARK: - Accessors
	func set(currentPageIndex: Int, byPagingScroll pagingScroll: Bool = false) {
		if self.firstTimeLoadPage || self.currentPageIndex != currentPageIndex {
			self.firstTimeLoadPage = false
			self.currentPageIndex = currentPageIndex
			
			if pagingScroll {
				self.delegate?.pagingScrollView(self, didScrollToPageAtIndex: currentPageIndex)
			}
		}
	}

	//MARK: - Reload data and build user interface
	/**
	Reload the specified page.
	@note It will call -pagingScrollView:imageForPageAtIndex: data source method to reload image for given page.
	*/
	func reloadPageAtIndex(_ pageIndex: Int) {
		self.imageCache[pageIndex] = nil
		
		for page in self.visiblePages {
			if page.index == pageIndex {
				self.configure(page, for: pageIndex)
				break
			}
		}
	}
	
	/**
	Reload all data to display a pagging view, including the total number of pages and the image for specific page.
	@note This method will build user interface from scratch and call all required methods in AFTPagingScrollViewDataSource.
	*/
	func reloadData() {
		// page count
		self.pageCount = 0
		self.pageCount = self.dataSource?.numberOfPages(in: self)
		if pageCount < 0 { pageCount = 0 }
		
		// page padding
		if pagePadding < 0 { pagePadding = 0 }
		
		if isParallaxScrollingEnabled {
			parallaxPagePadding = pagePadding > 0 ? pagePadding : 20
			pagePadding = 0
		}
		
		// build interface
		for subview in self.subviews {
			subview.removeFromSuperview()
		}
		self.buildInterface()
	}
	
	func buildInterface() {
		// Build paging scroll view
		let pagingScrollViewFrame = self.frameForPagingScrollView()
		
		self.pagingScrollView = UIScrollView(frame: pagingScrollViewFrame)
		pagingScrollView.isPagingEnabled = true
		pagingScrollView.showsVerticalScrollIndicator = false
		pagingScrollView.showsHorizontalScrollIndicator = false
//		pagingScrollView.bounces = false
		pagingScrollView.contentSize = self.contentSizeForPagingScrollView()
		pagingScrollView.delegate = self
		
		if self.isHorizontalDirection {
			pagingScrollView.alwaysBounceVertical = false
			pagingScrollView.alwaysBounceHorizontal = true
		} else {
			pagingScrollView.alwaysBounceVertical = true
			pagingScrollView.alwaysBounceHorizontal = false
		}
		
		self.addSubview(pagingScrollView)
		
		// Build parallax separator if necessary
		if isParallaxScrollingEnabled {
			var parallaxSeparatorFrame = CGRect.zero
			parallaxSeparatorFrame.size = self.sizeForParallaxSeparator()
			
			parallaxSeparator = UIView(frame: parallaxSeparatorFrame)
			pagingScrollView.addSubview(parallaxSeparator)
		}
		
		// Update background color
		self.updateBackgroundColor(to: self.backgroundColor!)
		
		// Display first page
		self.tilePages()
	}
	
	func tilePages() {
		// Calculate which pages should now be visible
		let visibleBounds = pagingScrollView.bounds
		let pageWidth = visibleBounds.size.width
		let pageHeight = visibleBounds.size.height
		
		var firstNeededPageIndex: Int = 0
		var lastNeededPageIndex: Int = 0
		
		if self.isHorizontalDirection {
			firstNeededPageIndex = Int(floor(visibleBounds.minX/visibleBounds.width))
			lastNeededPageIndex = Int(floor(visibleBounds.maxX - 1/visibleBounds.width))
		}
		else {
			firstNeededPageIndex = Int(floor(visibleBounds.minY/visibleBounds.height))
			lastNeededPageIndex = Int(floor(visibleBounds.maxY - 1/visibleBounds.height))
		}
		
		firstNeededPageIndex = max(firstNeededPageIndex, 0)
		lastNeededPageIndex = min(lastNeededPageIndex, self.pageCount - 1)
		
		let contentOffset = visibleBounds.origin
		let centerOffsetX = contentOffset.x + pageWidth / 2
		let centerOffsetY = contentOffset.y + pageHeight / 2

		var currentPageIndex = firstNeededPageIndex
		var nextPageIndex = firstNeededPageIndex

		if self.isHorizontalDirection {
			let lastPageStartX: CGFloat = CGFloat(lastNeededPageIndex) * pageWidth

			if lastPageStartX <= centerOffsetX {
				currentPageIndex = lastNeededPageIndex
			}

			if lastContentOffset.x > contentOffset.x {
				nextPageIndex = min(firstNeededPageIndex, lastNeededPageIndex)
			}
			else if lastContentOffset.x < contentOffset.x {
				nextPageIndex = max(firstNeededPageIndex, lastNeededPageIndex)
			}
		} else {
			let lastPageStartY = CGFloat(lastNeededPageIndex) * pageHeight
			if lastPageStartY <= centerOffsetY {
				currentPageIndex = lastNeededPageIndex
			}

			if lastContentOffset.y > contentOffset.y {
				nextPageIndex = min(firstNeededPageIndex, lastNeededPageIndex)
			}
			else if lastContentOffset.y < contentOffset.y {
				nextPageIndex = max(firstNeededPageIndex, lastNeededPageIndex)
			}
		}

		lastContentOffset = contentOffset

		// Should continue
		if delegate!.pagingScrollView(self, shouldDisplayPageAtIndex: nextPageIndex) {
			self.nextPageIndex = nextPageIndex
		}
		else {
			// reset paging offset
			let offset = self.contentOffsetForPagingEnabledAt(currentPageIndex)
			self.pagingScrollView.setContentOffset(offset, animated: false)
			return
		}
		
		//Recycle no longer needs pages
		for page in self.visiblePages {
			if page.index < firstNeededPageIndex || page.index > lastNeededPageIndex {
				self.recycledPages.insert(page)
				page.removeFromSuperview()
				
				self.delegate?.pagingScrollView(self, didRecycleImageScrollView: page, forPageIndex: page.index)
			}
		}
		self.visiblePages.subtract(self.recycledPages)
		
		//add missing pages
		for index in firstNeededPageIndex...lastNeededPageIndex {
			if !self.isDisplayingPage(forIndex: index) {
				let page = self.dequeueRecycledPage() ?? TImageScrollView(pagingScrollView: self)
				self.configure(page, for: index)
				self.pagingScrollView.addSubview(page)
				self.visiblePages.insert(page)
				
				self.delegate?.pagingScrollView(self, didReuseImageScrollView: page, forPageIndex: page.index)
				
				if isParallaxScrollingEnabled {
					self.pagingScrollView.bringSubview(toFront: self.parallaxSeparator)
				}
			}
		}
		
		self.set(currentPageIndex: currentPageIndex, byPagingScroll: true)
		
		// Apply parallax scrolling if necessary
		if isParallaxScrollingEnabled {
			self.applyParallaxScrollingEffect()
		}
	}
	
	/**
	Jump to the specified page.
	@note It will call -pagingScrollView:didDisplayPageAtIndex: delegate method.
	*/
	func displayPageAtIndex(_ pageIndex: Int) {
		if pageIndex >= self.pageCount {
			return
		}
		
		if self.delegate!.pagingScrollView(self, shouldDisplayPageAtIndex: pageIndex) {
			self.nextPageIndex = pageIndex
		}
		else {
			return
		}
		
		// Recycle no-longer-visible pages
		for page in self.visiblePages {
			if page.index != pageIndex {
				self.recycledPages.insert(page)
				page.removeFromSuperview()
				
				self.delegate?.pagingScrollView(self, didRecycleImageScrollView: page, forPageIndex: page.index)
			}
		}
		self.visiblePages.subtract(self.recycledPages)
		
		// Add missing pages
		if !self.isDisplayingPage(forIndex: pageIndex) {
			let page = self.dequeueRecycledPage() ?? TImageScrollView(pagingScrollView: self)
			self.configure(page, for: pageIndex)
			self.pagingScrollView.addSubview(page)
			self.visiblePages.insert(page)
			
			// Jump to specified page without calling -scrollViewDidScroll: method
			var pagingBounds: CGRect = self.pagingScrollView.bounds
			
			if self.isHorizontalDirection {
				pagingBounds.origin.x = page.frame.origin.x - self.pagePadding
			} else {
				pagingBounds.origin.y = page.frame.origin.y - self.pagePadding
			}
			
			pagingScrollView.bounds = pagingBounds
			
 			self.delegate?.pagingScrollView(self, didReuseImageScrollView: page, forPageIndex: page.index)
			
		}
		
		self.currentPageIndex = pageIndex
		self.delegate?.pagingScrollView(self, didDisplayPageAtIndex: pageIndex)
		self.updateImageCache()
	}
	
	
	func dequeueRecycledPage() -> TImageScrollView? {
		if let page = self.recycledPages.first {
			self.recycledPages.remove(page)
			return page
		}
		return nil
	}
	
	
	func isDisplayingPage(forIndex index: Int) -> Bool {
		for page in self.visiblePages {
			if page.index == index {
				return true
			}
		}
		return false
	}
	
	func configure(_ page: TImageScrollView, for index: Int) {
		page.index = index
		page.frame = self.frameForPage(at: index)
		page.backgroundColor = self.backgroundColor
		
		var image = self.imageCache[index]
		if image == nil {
			image = self.dataSource?.pagingScrollView(self, imageForPageAtIndex: index)
			self.imageCache[index] = image
		}
		
		page.display(image!)
		
		// Use tiled images
//		page.displayTiledImage(named: self.imageName(at: index), size: self.imageSizeAt(index: index))
		
		// To use full images instead of tiled images, replace the "displayTiledImageNamed:" call
		// above by the following line:
		//		 page.display(self.image(at: index))
	}

	//MARK: - UIScrollViewDelegate
	
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		self.tilePages()
	}

	func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
		self.delegate?.pagingScrollViewWillBeginPaging(self)
	}
	
	func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
		self.delegate?.pagingScrollView(self, didDisplayPageAtIndex: self.currentPageIndex)
		self.updateImageCache()
	}
	
	//MARK: - Calculations
	
	func frameForPagingScrollView() -> CGRect {
		let padding = self.pagePadding
		var frame = UIScreen.main.bounds //[[UIScreen mainScreen] bounds]

		if self.isHorizontalDirection {
			frame.origin.x -= padding
			frame.size.width += 2*padding
		}
		else {
			frame.origin.y -= padding
			frame.size.height += 2*padding
		}
		
		return frame
	}
	
	func frameForPage(at index: Int) -> CGRect {
		// We have to use our paging scroll view's bounds, not frame, to calculate the page placement. When the device is in
		// landscape orientation, the frame will still be in portrait because the pagingScrollView is the root view controller's
		// view, so its frame is in window coordinate space, which is never rotated. Its bounds, however, will be in landscape
		// because it has a rotation transform applied.
		
		let padding = self.pagePadding
		let bounds = self.pagingScrollView.bounds
		var pageFrame = bounds
		
		if self.isHorizontalDirection {
			pageFrame.size.width -= 2*padding
			pageFrame.origin.x = (bounds.size.width*CGFloat(index)) + padding
		}
		else {
			pageFrame.size.height -= 2*padding
			pageFrame.origin.y = (bounds.size.width*CGFloat(index)) + padding
		}
		return pageFrame
	}
	
	func sizeForParallaxSeparator() -> CGSize {
		var parallaxSeparatorSize = CGSize.zero
		let pagingSize = self.frameForPagingScrollView().size
		
		if self.isHorizontalDirection {
			parallaxSeparatorSize.width = parallaxPagePadding * 2
			parallaxSeparatorSize.height = max(pagingSize.width, pagingSize.height)
		} else {
			parallaxSeparatorSize.height = parallaxPagePadding * 2
			parallaxSeparatorSize.width = max(pagingSize.width, pagingSize.height)
		}
		
		return parallaxSeparatorSize;

	}

	func contentSizeForPagingScrollView() -> CGSize {
		// We have to use the paging scroll view's bounds to calculate the contentSize, for the same reason outlined above.
		let bounds = self.pagingScrollView.bounds
		var size = CGSize.zero
		
		if self.isHorizontalDirection {
			size.width = bounds.size.width * CGFloat(pageCount)
		}
		else {
			size.height = bounds.size.height * CGFloat(pageCount)
		}
		
		return size
	}

	func contentOffsetForPagingEnabledAt(_ pageIndex: Int) -> CGPoint {
		var bounds = pagingScrollView.bounds
		
		if self.isHorizontalDirection {
			let pageWidth = bounds.size.width
			let offsetX = CGFloat(pageIndex) * pageWidth
			bounds.origin.x = offsetX
		} else {
			let pageHeight = bounds.size.height;
			let offsetY = CGFloat(pageIndex) * pageHeight;
			bounds.origin.y = offsetY
		}
		
		return bounds.origin
	}
	
	// Not used here.
	func contentOffsetFrom(_ targetContentOffset: CGPoint) -> CGPoint {
		var contentOffset = targetContentOffset
		let pageWidth = pagingScrollView.bounds.size.width
		let overshoot = CGFloat(fmod(contentOffset.x, pageWidth))
		if (overshoot < pageWidth / 2) {
			contentOffset.x -= overshoot
		} else {
			contentOffset.x += (pageWidth - overshoot)
		}
		return contentOffset;
	}
	
	//MARK: - Helper
	
	func updateBackgroundColor(to color: UIColor) {
		pagingScrollView?.backgroundColor = color
		parallaxSeparator?.backgroundColor = color
		
		for page in visiblePages {
			page.backgroundColor = color
		}
	}
	
	//MARK:  - Image Cache
	
	func updateImageCache() {
		let currentPage = currentPageIndex!
		let numberOfPages = pageCount!
		
		for page in 0..<numberOfPages {
			let pageKey = page
			let shouldCache = (page == currentPage || page == currentPage - 1 || page == currentPage + 1)
			
			// remove cached image
			if !shouldCache && imageCache[pageKey] != nil {
				imageCache[pageKey] = nil
			}
				
				// cache new image
			else if shouldCache && imageCache[pageKey] == nil {
				let image = self.dataSource?.pagingScrollView(self, imageForPageAtIndex: page)
				imageCache[pageKey] = image
			}
		}
		
		if PAGING_IMAGE_CACHE_LOG != 0 {
			var desc = String(format: "[%@] image cache indexes: ", arguments: [NSStringFromClass(type(of: self))])
			let allKeys = self.imageCache.keys.sorted(by: >)
			for cachedKey in allKeys {
				desc += "\(cachedKey)"
			}
			print(desc)
		}
	}
	
	@objc func removeImageCache() {
		self.imageCache.removeAll()
	}
	
	//MARK: - Parallax Scrolling
	
	func applyParallaxScrollingEffect() {
		let bounds = pagingScrollView.bounds
		var parallaxSeparatorFrame = parallaxSeparator.frame
		
		let offset = bounds.origin
		let pageWidth = bounds.size.width
		let pageHeight = bounds.size.height
		
		if self.isHorizontalDirection {
			let firstPageIndex = floor(bounds.minX / pageWidth)
			
			let x = offset.x - pageWidth * firstPageIndex;
			let percentage = x / pageWidth
			parallaxSeparatorFrame.origin.x = pageWidth * (firstPageIndex + 1) - parallaxSeparatorFrame.size.width * percentage

		} else {
			let firstPageIndex = floor(bounds.minY / pageHeight)
			
			let y = offset.y - pageHeight * firstPageIndex
			let percentage = y / pageHeight
			
			parallaxSeparatorFrame.origin.y = pageHeight * (firstPageIndex + 1) - parallaxSeparatorFrame.size.height * percentage
		}
		
		parallaxSeparator.frame = parallaxSeparatorFrame
//		parallaxSeparator.alpha = 0.5
	}
	
	//MARK: - Rotation
	/**
	Save current page and zooming states for device rotation.
	@note You can call it in UIViewController's -willRotateToInterfaceOrientation:duration: or -willTransitionToTraitCollection:withTransitionCoordinator:
	*/
	func saveCurrentStatesForRotation() {
		var offset: CGFloat = 0
		var pageLength: CGFloat = 0
		
		if self.isHorizontalDirection {
			offset = pagingScrollView?.contentOffset.x ?? 0
			pageLength = pagingScrollView?.bounds.size.width ?? 1
		} else {
			offset = pagingScrollView?.contentOffset.y ?? 0
			pageLength = pagingScrollView?.bounds.size.height ?? 1
		}
		
		if (offset >= 0) {
			firstVisiblePageIndexBeforeRotation = Int(floor(offset / pageLength))
			percentScrolledIntoFirstVisiblePage = (offset - (CGFloat(firstVisiblePageIndexBeforeRotation) * pageLength)) / pageLength
		} else {
			firstVisiblePageIndexBeforeRotation = 0
			percentScrolledIntoFirstVisiblePage = offset / pageLength
		}
	}
	
	/**
	Apply tracked informations for device rotation.
	@note You can call it in UIViewController's -willAnimateRotationToInterfaceOrientation:duration:
	*/
	func restoreStatesForRotation() {
		// recalculate contentSize based on current orientation
		let pagingScrollViewFrame = self.frameForPagingScrollView()
		pagingScrollView?.frame = pagingScrollViewFrame
		pagingScrollView?.contentSize = self.contentSizeForPagingScrollView()
		
		// adjust frames and configuration of each visible page
		for page in visiblePages {
			let restorePoint = page.pointToCenterAfterRotation()
			let restoreScale = page.scaleToRestoreAfterRotation()
			page.frame = self.frameForPage(at: page.index)
			page.setMaxMinZoomScaleForCurrentBounds()
			page.restoreCenterPoint(oldCenter: restorePoint, oldScale: restoreScale)
		}
		
		// adjust contentOffset to preserve page location based on values collected prior to location
		var contentOffset = CGPoint.zero
		
		if self.isHorizontalDirection {
			let pageWidth = pagingScrollView?.bounds.size.width ?? 1
			contentOffset.x = (CGFloat(firstVisiblePageIndexBeforeRotation) * pageWidth) + (percentScrolledIntoFirstVisiblePage * pageWidth)
		} else {
			let pageHeight = pagingScrollView?.bounds.size.height ?? 1
			contentOffset.y = (CGFloat(firstVisiblePageIndexBeforeRotation) * pageHeight) + (percentScrolledIntoFirstVisiblePage * pageHeight)
		}
		
		pagingScrollView?.contentOffset = contentOffset
		
		// adjust position for parallax bar
		if isParallaxScrollingEnabled {
			self.applyParallaxScrollingEffect()
		}
	}
	
	/**
	Same as -restoreStatesForRotation.
	@note You can pass size from in UIViewController's -viewWillTransitionToSize:withTransitionCoordinator:
	*/
	func restoreStatesForRotation(in size: CGSize) {
		var bounds = self.bounds
		if bounds.size != size {
			bounds.size = size

			self.bounds = bounds
			pagingScrollView.bounds = bounds
			
			self.restoreStatesForRotation()
		}
	}
	
	//MARK: - Interface Builder
	
	// Quote From WWDC: This is going to be invoked on our view right before it renders into the canvas, and it's a last miniute chance for us to do any additional setup.
	override func prepareForInterfaceBuilder() {
		self.backgroundColor = .black
	}

}
