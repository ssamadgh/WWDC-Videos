//
//  ImageScrollView.swift
//  FrogsDemoSwift
//
//  Created by Seyed Samad Gholamzadeh on 8/30/1396 AP.
//  Copyright © 1396 AP Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

let useTiledImages: Bool = true

class ImageScrollView: UIScrollView, UIScrollViewDelegate {
	
	var index: Int!
	var zoomView: UIImageView!
	var imageSize: CGSize!
	var tilingView: TilingView?

	lazy var zoomingTap: UITapGestureRecognizer = {
		let zoomingTap = UITapGestureRecognizer(target: self, action: #selector(handleZoomingTap(_:)))
		zoomingTap.numberOfTapsRequired = 2
		
		return zoomingTap
	}()

	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		self.showsVerticalScrollIndicator = false
		self.showsHorizontalScrollIndicator = false
		self.bouncesZoom = true
		self.decelerationRate = UIScrollViewDecelerationRateFast
		self.delegate = self
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		centerImage()
		
	}
	
	func centerImage() {
		// center the zoom view as it becomes smaller than the size of the screen
		let boundsSize = self.bounds.size
		var frameToCenter = zoomView.frame
		
		// center horizontally
		if frameToCenter.size.width < boundsSize.width {
			frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width)/2
		}
		else {
			frameToCenter.origin.x = 0
		}
		
		// center vertically
		if frameToCenter.size.height < boundsSize.height {
			frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height)/2
		}
		else {
			frameToCenter.origin.y = 0
		}
		
		zoomView.frame = frameToCenter
	}
	
	//MArk:  - UIScrollViewDelegate
	func viewForZooming(in scrollView: UIScrollView) -> UIView? {
		return zoomView
	}
	
	func scrollViewDidZoom(_ scrollView: UIScrollView) {
		centerImage()
	}
	
	
	//MARK: - Configure scrollView to display new image (tiled or not)
	
	func display(_ image: UIImage) {
		
		// clear the previous image
		zoomView?.removeFromSuperview()
		zoomView = nil
		// reset our zoomScale to 1.0 before doing any further calculations
		self.zoomScale = 1.0
		
		// make a new UIImageView for the new image
		zoomView = UIImageView(image: image)
		self.addSubview(zoomView)

		self.configureFor(imageSize: image.size)
	}

	func displayTiledImage(named imageName: String, size imageSize: CGSize) {
		
		// clear views for the previous image
		zoomView?.removeFromSuperview()
		zoomView = nil
		tilingView = nil

		// reset our zoomScale to 1.0 before doing any further calculations
		self.zoomScale = 1.0
		
		// make views to display the new image
		zoomView = UIImageView(frame: CGRect(origin: CGPoint.zero, size: imageSize))
		let image = placeholderImage(named: imageName)
		zoomView.image = image
		self.addSubview(zoomView)
		
		self.tilingView = TilingView(imageName: imageName, size: imageSize)
		self.tilingView?.frame = self.zoomView.bounds
		self.zoomView.addSubview(self.tilingView!)

		self.configureFor(imageSize: imageSize)
	}
	
	
	func configureFor(imageSize: CGSize) {
		self.imageSize = imageSize
		self.contentSize = imageSize
		self.setMaxMinZoomScaleForCurrentBounds()
		self.zoomScale = self.minimumZoomScale
		
		// zoom tap
		self.zoomView.addGestureRecognizer(self.zoomingTap)
		self.zoomView.isUserInteractionEnabled = true

	}
	
	func setMaxMinZoomScaleForCurrentBounds() {
		let boundsSize = self.bounds.size
		let imageSize = zoomView.bounds.size
		
		// calculate min/max zoomscale
		let xScale =  boundsSize.width  / imageSize.width    // the scale needed to perfectly fit the image width-wise
		let yScale = boundsSize.height / imageSize.height  // the scale needed to perfectly fit the image height-wise
		
		var minScale = min(xScale, yScale)                 // use minimum of these to allow the image to become fully visible
		
		// on high resolution screens we have double the pixel density, so we will be seeing every pixel if we limit the
		// maximum zoom scale to 0.5.
//		let maxScale = 1.0/UIScreen.main.scale
		let maxScale = max(1.0, minScale)

		// don't let minScale exceed maxScale. (If the image is smaller than the screen, we don't want to force it to be zoomed.)
		if minScale > maxScale {
			minScale = maxScale
		}
		
		self.maximumZoomScale = maxScale
		self.minimumZoomScale = minScale
		
	}
	
	func diffrenceOfImageAndScrollView() -> CGFloat {
		let diff = self.bounds.width - self.imageSize.width*self.minimumZoomScale
		return diff/2
	}
	
	//MARK: - Methods called during rotation to preserve the zoomScale and the visible portion of the image
	
	// returns the center point, in image coordinate space, to try to restore after rotation.
	func pointToCenterAfterRotation() -> CGPoint {
		let boundsCenter = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
		return self.convert(boundsCenter, to: zoomView)
	}
	
	// returns the zoom scale to attempt to restore after rotation.
	func scaleToRestoreAfterRotation() -> CGFloat {
		var contentScale = self.zoomScale
		
		// If we're at the minimum zoom scale, preserve that by returning 0, which will be converted to the minimum
		// allowable scale when the scale is restored.
		if contentScale <= self.minimumZoomScale + CGFloat.ulpOfOne {
			contentScale = 0
		}
		
		return contentScale
	}
	
	func maximumContentOffset() -> CGPoint {
		let contentSize = self.contentSize
		let boundSize = self.bounds.size
		return CGPoint(x: contentSize.width - boundSize.width, y: contentSize.height - boundSize.height)
	}
	
	func minimumContentOffset() -> CGPoint {
		
		return CGPoint.zero
	}
	
	func restoreCenterPoint(oldCenter: CGPoint, oldScale: CGFloat) {

		// Step 1: restore zoom scale, first making sure it is within the allowable range.
		self.zoomScale = min(self.maximumZoomScale, max(self.minimumZoomScale, oldScale))
		
		
		// Step 2: restore center point, first making sure it is within the allowable range.
		
		// 2a: convert our desired center point back to our own coordinate space
		let boundsCenter = self.convert(oldCenter, from: zoomView)
		// 2b: calculate the content offset that would yield that center point
		var offset = CGPoint(x: boundsCenter.x - self.bounds.size.width/2.0, y: boundsCenter.y - self.bounds.size.height/2.0)
		// 2c: restore offset, adjusted to be within the allowable range
		let maxOffset = self.maximumContentOffset()
		let minOffset = self.minimumContentOffset()
		offset.x = max(minOffset.x, min(maxOffset.x, offset.x))
		offset.y = max(minOffset.y, min(maxOffset.y, offset.y))
		self.contentOffset = offset
	}
	
	//MARK: - Zoom tap
	
	@objc func handleZoomingTap(_ sender: UITapGestureRecognizer) {
		
		let location = sender.location(in: sender.view)
		self.zoom(to: location, animated: true)
		
	}
	
	func zoom(to point: CGPoint, animated: Bool) {
		let currentScale = self.zoomScale
		let minScale = self.minimumZoomScale
		let maxScale = self.maximumZoomScale
		
		if (minScale == maxScale && minScale > 1) {
			return;
		}
		
		let toScale = maxScale
		let finalScale = (currentScale == minScale) ? toScale : minScale
		let zoomRect = self.zoomRect(forScale: finalScale, withCenter: point)
		self.zoom(to: zoomRect, animated: animated)
	}
	
	// The center should be in the imageView's coordinates
	func zoomRect(forScale scale: CGFloat, withCenter center: CGPoint) -> CGRect {
		var zoomRect = CGRect.zero
		let bounds = self.bounds
		
		// the zoom rect is in the content view's coordinates.
		//At a zoom scale of 1.0, it would be the size of the imageScrollView's bounds.
		//As the zoom scale decreases, so more content is visible, the size of the rect grows.
		zoomRect.size.width = bounds.size.width / scale
		zoomRect.size.height = bounds.size.height / scale
		
		// choose an origin so as to get the right center.
		zoomRect.origin.x = center.x - (zoomRect.size.width / 2.0)
		zoomRect.origin.y = center.y - (zoomRect.size.height / 2.0)
		
		return zoomRect
	}

	
	
}

func placeholderImage(named name: String) -> UIImage {
	return UIImage(named: String(format: "%@_Placeholder", name))!
}



