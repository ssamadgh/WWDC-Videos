//
//  ImageScrollView.swift
//  LargeImageSwift
//
//  Created by Seyed Samad Gholamzadeh on 1/7/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

class ImageScrollView: UIScrollView, UIScrollViewDelegate {

	// The TiledImageView that is currently front most
	var frontTiledView: TiledImageView!
	
	// The old TiledImageView that we draw on top of when the zooming stops
	var backTiledView: TiledImageView!
	
	// A low res version of the image that is displayed until the TiledImageView
	// renders its content.
	var backgroundImageView: UIImageView!
	
	var minimumScale: CGFloat!
	
	// current image zoom scale
	var imageScale: CGFloat!
	
	var image: UIImage!

	lazy var zoomingTap: UITapGestureRecognizer = {
		let zoomingTap = UITapGestureRecognizer(target: self, action: #selector(handleZoomingTap(_:)))
		zoomingTap.numberOfTapsRequired = 2
		
		return zoomingTap
	}()

	
	init(frame: CGRect, image: UIImage) {
		super.init(frame: frame)
		
		// Set up the UIScrollView
		self.showsVerticalScrollIndicator = false
		self.showsHorizontalScrollIndicator = false
		self.bouncesZoom = true
		self.decelerationRate = UIScrollViewDecelerationRateFast
		self.delegate = self
		self.maximumZoomScale = 5.0
		self.minimumZoomScale = 0.25
		self.backgroundColor = UIColor(red: 0.4, green: 0.2, blue: 0.2, alpha: 1.0)
		
		// determine the size of the image
		self.image = image
		var imageRect = CGRect(origin: .zero, size: CGSize(width: image.cgImage!.width, height: image.cgImage!.height))
		self.imageScale = self.frame.size.width/imageRect.size.width
		self.minimumScale = imageScale * 0.75
		print("imageScale is : ",imageScale)
		imageRect.size = CGSize(width: imageRect.size.width*imageScale, height: imageRect.size.height*imageScale)
		
		// Create a low res image representation of the image to display before the TiledImageView
		// renders its content.
		UIGraphicsBeginImageContext(imageRect.size)
		let context = UIGraphicsGetCurrentContext()
		
		context?.saveGState()
		context?.draw(image.cgImage!, in: imageRect)
		context?.restoreGState()
		let backgroundImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		
		self.backgroundImageView = UIImageView(image: backgroundImage)
		backgroundImageView.frame = imageRect
		backgroundImageView.contentMode = .scaleAspectFit
		self.addSubview(backgroundImageView)
		self.sendSubview(toBack: backgroundImageView)

		// Create the TiledImageView based on the size of the image and scale it to fit the view.
		self.frontTiledView = TiledImageView(frame: imageRect, image: image, scale: self.imageScale)
		self.addSubview(frontTiledView)
		
		self.addGestureRecognizer(self.zoomingTap)
		self.isUserInteractionEnabled = true
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	deinit {
		self.frontTiledView = nil
		self.backTiledView = nil
		self.backgroundImageView = nil
		self.image = nil
	}
	
	//MARK: - Override layoutSubviews to center content
	
	// We use layoutSubviews to center the image in the view
	override func layoutSubviews() {
		super.layoutSubviews()
		
		self.centerImage()
	}
	
	func centerImage() {
		// center the image as it becomes smaller than the size of the screen
		let boundsSize = self.bounds.size;
		var frameToCenter = self.frontTiledView.frame;
		
		// center horizontally
		if frameToCenter.size.width < boundsSize.width {
			frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2
		} else {
			frameToCenter.origin.x = 0
		}
		
		// center vertically
		if (frameToCenter.size.height < boundsSize.height) {
			frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2
		} else {
			frameToCenter.origin.y = 0
		}
		
		self.frontTiledView.frame = frameToCenter
		self.backgroundImageView.frame = frameToCenter
	}

	//MARK: - UIScrollView delegate methods
	
	// A UIScrollView delegate callback, called when the user starts zooming.
	// We return our current TiledImageView.
	func viewForZooming(in scrollView: UIScrollView) -> UIView? {
		return self.frontTiledView
	}
	
	// A UIScrollView delegate callback, called when the user stops zooming.  When the user stops zooming
	// we create a new TiledImageView based on the new zoom level and draw it on top of the old TiledImageView.
	func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
		
		// set the new scale factor for the TiledImageView
		self.imageScale! *= scale
		if imageScale < minimumScale { imageScale = minimumScale }
		let imageRect = CGRect(origin: .zero, size: CGSize(width: CGFloat(image.cgImage!.width) * self.imageScale!, height: CGFloat(image.cgImage!.height) * self.imageScale!))

		// Create a new TiledImageView based on new frame and scaling.
		self.frontTiledView = TiledImageView(frame: imageRect, image: image, scale: self.imageScale)
		self.addSubview(frontTiledView)
	}
	
	// A UIScrollView delegate callback, called when the user begins zooming.  When the user begins zooming
	// we remove the old TiledImageView and set the current TiledImageView to be the old view so we can create a
	// a new TiledImageView when the zooming ends.
	func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
		// Remove back tiled view.
		self.backTiledView?.removeFromSuperview()
		// Set the current TiledImageView to be the old view.
		self.backTiledView = frontTiledView
	}
	
	func scrollViewDidZoom(_ scrollView: UIScrollView) {
		self.centerImage()
	}
		
	//MARK: - ZoomTap
	
	@objc func handleZoomingTap(_ sender: UITapGestureRecognizer) {
		let location = sender.location(in: sender.view)
		self.zoom(to: location, animated: true)
	}
	
	func zoom(to point: CGPoint, animated: Bool) {
		let currentScale = self.imageScale
		let minScale = self.minimumZoomScale
		let maxScale = self.maximumZoomScale
		
		if (minScale == maxScale && minScale > 1) {
			return;
		}
		
		let toScale = maxScale
		let finalScale = (currentScale == minScale) ? toScale : minScale
		self.imageScale = finalScale
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
