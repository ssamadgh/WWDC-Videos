//
//  PhotoViewController.swift
//  PhotoScrollerSwift
//
//  Created by Seyed Samad Gholamzadeh on 10/4/1396 AP.
//  Copyright © 1396 AP Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

class PhotoViewController: UIViewController, UIScrollViewDelegate {
	
	private var pagePadding: CGFloat = 0
	private var parallaxPagePadding: CGFloat = 0
	
	//	var isHorizontalDirection: Bool {
	//		return true
	//	}
	
	var pagingScrollView: UIScrollView!
	var parallaxSeparator: UIView!
	var isParallaxScrollingEnabled: Bool = true
	var recycledPages: Set<ImageScrollView>!
	var visiblePages: Set<ImageScrollView>!
	
	// these values are stored off before we start rotation so we adjust our content offset appropriately during rotation
	var firstVisiblePageIndexBeforeRotation: Int!
	var percentScrolledIntoFirstVisiblePage: CGFloat!
	
	lazy var imageData: [Any]? = {
		var data: [Any]? = nil
		
		DispatchQueue.global().sync {
			let path = Bundle.main.url(forResource: "ImageData", withExtension: "plist")
			do {
				let plistData = try Data(contentsOf: path!)
				data = try PropertyListSerialization.propertyList(from: plistData, options: PropertyListSerialization.ReadOptions.mutableContainers, format: nil) as? [Any]
				//				return data
			}
			catch {
				print("Unable to read image data: ", error)
			}
			
		}
		return data
	}()
	
	
	lazy var imageCount: Int = {
		return self.imageData?.count ?? 0
	}()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Step 1: make the outer paging scroll view
		self.view.backgroundColor = UIColor.black
		
		let pagingScrollViewFrame = self.frameForPagingScrollView()
		
		self.pagingScrollView = UIScrollView(frame: pagingScrollViewFrame)
		self.pagingScrollView.isPagingEnabled = true
		self.pagingScrollView.backgroundColor = UIColor.black
		self.pagingScrollView.showsVerticalScrollIndicator = false
		self.pagingScrollView.showsHorizontalScrollIndicator = false
		self.pagingScrollView.contentSize = self.contentSizeForPagingScrollView()
		self.pagingScrollView.delegate = self
		self.automaticallyAdjustsScrollViewInsets = false
		self.view.addSubview(self.pagingScrollView)
		
		// Build parallax separator if necessary
		if isParallaxScrollingEnabled {
			parallaxPagePadding = pagePadding > 0 ? pagePadding : 20
			
			var parallaxSeparatorFrame = CGRect.zero
			parallaxSeparatorFrame.size = self.sizeForParallaxSeparator()
			
			parallaxSeparator = UIView(frame: parallaxSeparatorFrame)
			parallaxSeparator.backgroundColor = .black
			pagingScrollView.addSubview(parallaxSeparator)
			
		}
		
		// Step 2: prepare to tile content
		self.recycledPages = []
		self.visiblePages = []
		self.tilePages()
		
	}
	
	deinit {
		self.pagingScrollView = nil
		self.recycledPages = nil
		self.visiblePages = nil
	}
	
	//MARK: - Tiling and page configuration
	
	func tilePages() {
		// Calculate which pages should now be visible
		let visibleBounds = pagingScrollView.bounds
		
		var firstNeededPageIndex: Int = Int(floor(visibleBounds.minX/visibleBounds.width))
		var lastNeededPageIndex: Int = Int(floor(visibleBounds.maxX - 1/visibleBounds.width))
		firstNeededPageIndex = max(firstNeededPageIndex, 0)
		lastNeededPageIndex = min(lastNeededPageIndex, self.imageCount - 1)
		
		//Recycle no longer needs pages
		for page in self.visiblePages {
			if page.index < firstNeededPageIndex || page.index > lastNeededPageIndex {
				self.recycledPages.insert(page)
				page.removeFromSuperview()
			}
		}
		self.visiblePages.subtract(self.recycledPages)
		
		//add missing pages
		for index in firstNeededPageIndex...lastNeededPageIndex {
			if !self.isDisplayingPage(forIndex: index) {
				let page = self.dequeueRecycledPage() ?? ImageScrollView()
				//				self.performSelector(onMainThread: #selector(config(pageDic:)), with: [index: page], waitUntilDone: true)
				self.configure(page, for: index)
				self.pagingScrollView.addSubview(page)
				self.visiblePages.insert(page)
				
				if isParallaxScrollingEnabled {
					self.pagingScrollView.bringSubview(toFront: self.parallaxSeparator)
				}
				
			}
		}
		
		// Apply parallax scrolling if necessary
		if isParallaxScrollingEnabled {
			self.applyParallaxScrollingEffect()
		}
		
	}
	
	func dequeueRecycledPage() -> ImageScrollView? {
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
	
	func configure(_ page: ImageScrollView, for index: Int) {
		page.index = index
		page.frame = self.frameForPage(at: index)
		
		// Use tiled images
		//		page.displayTiledImage(named: self.imageName(at: index), size: self.imageSizeAt(index: index))
		
		// To use full images instead of tiled images, replace the "displayTiledImageNamed:" call
		// above by the following line:
		page.display(self.image(at: index))
	}
	
	//MARK: - ScrollView delegate methods
	
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		self.tilePages()
	}
	
	//MARK: - View controller rotation methods
	
	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		// here, our pagingScrollView bounds have not yet been updated for the new interface orientation. So this is a good
		// place to calculate the content offset that we will need in the new orientation
		let offset = pagingScrollView.contentOffset.x
		let pageWidth = pagingScrollView.bounds.size.width
		
		if offset >= 0 {
			self.firstVisiblePageIndexBeforeRotation = Int(floor(offset / pageWidth))
			self.percentScrolledIntoFirstVisiblePage = (offset - (CGFloat(firstVisiblePageIndexBeforeRotation) * pageWidth))/pageWidth
		}
		else {
			self.firstVisiblePageIndexBeforeRotation = 0
			self.percentScrolledIntoFirstVisiblePage = offset / pageWidth
		}
		
		// recalculate contentSize based on current orientation
		
		let pagingScrollViewFrame = self.frameForPagingScrollView(withSize: size)
		self.pagingScrollView.frame = pagingScrollViewFrame
		
		self.pagingScrollView.contentSize = self.contentSizeForPagingScrollView()
		
		// adjust frames and configuration of each visible page
		for page in self.visiblePages {
			let restorePoint = page.pointToCenterAfterRotation()
			let restoreScale = page.scaleToRestoreAfterRotation()
			page.frame = self.frameForPage(at: page.index)
			page.setMaxMinZoomScaleForCurrentBounds()
			page.restoreCenterPoint(oldCenter: restorePoint, oldScale: restoreScale)
		}
	}
	
	
	
	//MARK: - Frame calculations
	
	func frameForPagingScrollView(withSize size: CGSize? = nil) -> CGRect {
		var frame = UIScreen.main.bounds //[[UIScreen mainScreen] bounds]
		if size != nil {
			frame.size = size!
		}
		frame.origin.x -= pagePadding
		frame.size.width += 2*pagePadding
		return frame
	}
	
	func frameForPage(at index: Int) -> CGRect {
		// We have to use our paging scroll view's bounds, not frame, to calculate the page placement. When the device is in
		// landscape orientation, the frame will still be in portrait because the pagingScrollView is the root view controller's
		// view, so its frame is in window coordinate space, which is never rotated. Its bounds, however, will be in landscape
		// because it has a rotation transform applied.
		
		let bounds = self.pagingScrollView.bounds
		var pageFrame = bounds
		pageFrame.size.width -= 2*pagePadding
		pageFrame.origin.x = (bounds.size.width*CGFloat(index)) + pagePadding
		return pageFrame
	}
	
	func contentSizeForPagingScrollView() -> CGSize {
		// We have to use the paging scroll view's bounds to calculate the contentSize, for the same reason outlined above.
		let bounds = self.pagingScrollView.bounds
		return CGSize(width: bounds.size.width*CGFloat(self.imageCount), height: bounds.size.height)
	}
	
	//MARK: - Image Wrangling
	
	func imageName(at index: Int) -> String {
		if let info = imageData?[index] as? [String: Any] {
			return info["name"] as? String ?? ""
		}
		return ""
	}
	
	// we use "imageWithContentsOfFile:" instead of "imageNamed:" here to avoid caching
	func image(at index: Int) -> UIImage {
		let name = imageName(at: index)
		if let path = Bundle.main.path(forResource: name, ofType: "jpg") {
			return UIImage(contentsOfFile: path)!
		}
		return UIImage()
	}
	
	func imageSizeAt(index: Int) -> CGSize {
		if let info = imageData?[index] as? [String: Any] {
			return CGSize(width: info["width"] as? CGFloat ?? 0, height: info["height"] as? CGFloat ?? 0)
		}
		return CGSize.zero
	}
	
	func sizeForParallaxSeparator() -> CGSize {
		var parallaxSeparatorSize = CGSize.zero
		let pagingSize = self.frameForPagingScrollView().size
		
		parallaxSeparatorSize.width = parallaxPagePadding * 2
		parallaxSeparatorSize.height = max(pagingSize.width, pagingSize.height)
		
		return parallaxSeparatorSize;
		
	}
	
	
	func applyParallaxScrollingEffect() {
		let bounds = pagingScrollView.bounds
		var parallaxSeparatorFrame = parallaxSeparator.frame
		var imagesDiff: CGFloat = 0
		
		let offset = bounds.origin
		let pageWidth = bounds.size.width
		//		let pageHeight = bounds.size.height
		
		let firstPageIndex = floor(bounds.minX / pageWidth)
		var currentPageEdgeDiff: CGFloat = 0
		var nextPageEdgeDiff: CGFloat = 0

		for page in self.visiblePages {
			if page.index == Int(firstPageIndex) {
				currentPageEdgeDiff = page.diffrenceOfImageAndScrollView()
				imagesDiff += page.diffrenceOfImageAndScrollView()
			}
			if page.index == Int(firstPageIndex) + 1 {
				imagesDiff += page.diffrenceOfImageAndScrollView()
				nextPageEdgeDiff = page.diffrenceOfImageAndScrollView()

			}
		}
		print(currentPageEdgeDiff)

		parallaxSeparatorFrame.size.width = imagesDiff + parallaxPagePadding*2

		let x = offset.x - pageWidth * firstPageIndex;
		let percentage = x / pageWidth
		
//		parallaxSeparatorFrame.origin.x = pageWidth * (firstPageIndex + 1) - parallaxSeparatorFrame.size.width * percentage
		parallaxSeparatorFrame.origin.x = pageWidth * (firstPageIndex + 1) - currentPageEdgeDiff + nextPageEdgeDiff - parallaxSeparatorFrame.size.width * percentage

		
		parallaxSeparator.frame = parallaxSeparatorFrame
		parallaxSeparator.alpha = 1
	}
	
	
}

