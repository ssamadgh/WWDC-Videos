//
//  ImageBrowserItemLayer.swift
//  ImageBrowser
//
//  Created by Seyed Samad Gholamzadeh on 2/2/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

 class ImageBrowserItemLayer: CALayer {
	
	var imageURL: URL! {
		didSet {
			self.image = nil
			self.loadImage()
		}
	}
	
	var image: UIImage! {
		didSet {
			if !downSampleImages {
				self.contents = self.image?.cgImage
				self.setNeedsLayout()
			}
			else {
				self.setNeedsDisplay()
			}
		}
	}
	
	static var imageThreadRunning: Bool = false
	static var imageQueue: [ImageBrowserItemLayer]!
	
	override init() {
		super.init()
		if downSampleImages {
			self.needsDisplayOnBoundsChange = true
		}
		else {
			self.contentsGravity = kCAGravityResizeAspect
			self.shadowOpacity = 0.5
			self.shadowRadius = 5
			self.shadowOffset = CGSize(width: 0, height: 6)
			
			if useShadowPath {
				self.shadowPath = UIBezierPath().cgPath
			}
		}
		
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	@discardableResult
	func loadImage() -> UIImage? {
		
		var image: UIImage!
		
		/* In case we're being called from the background thread. */
		
		CATransaction.lock()
		image = self.image
		CATransaction.unlock()
		
		if image == nil {
			if !useImageThread {
				image = self.loadImageInForeground()
			}
			else {
				self.loadImageInBackground()
			}
		}
		
		return image
	}
	
	override func layoutSublayers() {
		
		if useShadowPath && !downSampleImages {
			let image = self.loadImage()
			
			if image != nil {
				var size = image!.size
				var rect = self.bounds
				let scale = min(rect.size.width/size.width, rect.size.height/size.height)
				size.width *= scale
				size.height *= scale
				rect.origin.x += (rect.size.width - size.width)*0.5
				rect.size.width = size.width
				rect.origin.y += (rect.size.height - size.height)*0.5
				rect.size.height = size.height
				
				self.shadowPath = UIBezierPath(rect: rect).cgPath
			}
		}
		
	}
	
	//	DownSampel images
	override func draw(in ctx: CGContext) {
		super.draw(in: ctx)

		if downSampleImages {
			
			let bounds = self.bounds
			var image: UIImage!
			
			if self.isOpaque {
				ctx.setFillColor(gray: 1, alpha: 1)
				ctx.fill(bounds)
			}
			
			let color = UIColor(white: 0, alpha: 0.5).cgColor
			ctx.setShadow(offset: CGSize(width: 0, height: 6), blur: 10, color: color)
			
			image = self.loadImage()
			
			if image != nil {
				var size: CGSize = image.size
				var rect: CGRect = bounds.insetBy(dx: 8, dy: 8)
				let scale = min(rect.size.width/size.width, rect.size.height/size.height)
				size.width *= scale
				size.height *= scale
				rect.origin.x += (rect.size.width - size.width)*0.5
				rect.size.width = size.width
				rect.origin.y += (rect.size.height - size.height)*0.5
				rect.size.height = size.height
				
				ctx.saveGState()
				ctx.translateBy(x: 0, y: bounds.size.height)
				ctx.scaleBy(x: 1, y: -1)
				ctx.draw(image.cgImage!, in: rect)
				ctx.restoreGState()
			}
		}
	}
	
	@discardableResult
	func loadImageInForeground() -> UIImage? {
		
		self.image = UIImage(contentsOfFile: self.imageURL.path)
		
		CATransaction.lock()
		let image = self.image
		CATransaction.unlock()
		
		return image
	}
	
	func loadImageInBackground() {
		
		if self.imageURL != nil {
			
			CATransaction.lock()
			
			if ImageBrowserItemLayer.imageQueue == nil {
				ImageBrowserItemLayer.imageQueue = []
			}
			
			if ImageBrowserItemLayer.imageQueue.index(of: self) == nil  {
				ImageBrowserItemLayer.imageQueue.append(self)
				
				if !ImageBrowserItemLayer.imageThreadRunning {
					Thread.detachNewThreadSelector(#selector(ImageBrowserItemLayer.imageThread), toTarget: ImageBrowserItemLayer.self, with: nil)
					ImageBrowserItemLayer.imageThreadRunning = true
				}
			}
			
			CATransaction.unlock()
		}
	}
	
	@objc class func imageThread() {
		CATransaction.lock()
		
		while imageQueue.count != 0 {
			autoreleasepool {
				let layer = imageQueue.first
				CATransaction.unlock()
				layer!.loadImageInForeground()
				CATransaction.flush()
				CATransaction.lock()
				
				if let index = imageQueue.index(of: layer!) {
					imageQueue.remove(at: index)
				}
			}
		}
		imageThreadRunning = false
		CATransaction.unlock()
	}
	
	
	
	
	
	
	
	
}
