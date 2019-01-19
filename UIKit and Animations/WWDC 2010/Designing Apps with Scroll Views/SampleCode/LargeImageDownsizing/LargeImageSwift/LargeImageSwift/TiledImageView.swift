//
//  TiledImageView.swift
//  LargeImageSwift
//
//  Created by Seyed Samad Gholamzadeh on 1/7/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

class TiledImageView: UIView {
	
	var imageScale: CGFloat
	var image: UIImage
	var imageRect: CGRect
	
	override static var layerClass: AnyClass {
		return CATiledLayer.self
	}
	
	var tiledLayer: CATiledLayer {
		return self.layer as! CATiledLayer
	}
	
	// Force contentScaleFactor of 1, even on retina displays
	// For the CATiledLayer
	// to handle the interaction between CATiledLayer and high resolution screens, we need to manually set the
	// tiling view's contentScaleFactor to 1.0. (If we omitted this, it would be 2.0 on high resolution screens,
	// which would cause the CATiledLayer to ask us for tiles of the wrong scales.)
	override var contentScaleFactor: CGFloat {
		didSet {
			super.contentScaleFactor = 1
		}
	}

	
	// Create a new TiledImageView with the desired frame and scale.
	init(frame: CGRect, image: UIImage, scale: CGFloat) {
		
		self.image = image
		self.imageRect = CGRect(origin: .zero, size: CGSize(width: image.cgImage!.width, height: image.cgImage!.height))
		self.imageScale = scale

		super.init(frame: frame)

		// levelsOfDetail and levelsOfDetailBias determine how
		// the layer is rendered at different zoom levels. This
		// only matters while the view is zooming, since once the
		// the view is done zooming a new TiledImageView is created
		// at the correct size and scale.
		self.tiledLayer.levelsOfDetail = 4
		self.tiledLayer.levelsOfDetailBias = 4
		self.tiledLayer.tileSize = CGSize(width: 512.0, height: 512.0)
//		self.tiledLayer.tileSize = CGSize(width: 256.0, height: 256.0)

	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
    override func draw(_ rect: CGRect) {
		
		let context = UIGraphicsGetCurrentContext()
		

		context?.saveGState()
		// Scale the context so that the image is rendered
		// at the correct size for the zoom level.
		context?.scaleBy(x: self.imageScale, y: self.imageScale)

		context?.draw(self.image.cgImage!, in: imageRect)
		context?.restoreGState()
		
		UIColor.white.set()
		let scale = context?.ctm.a
		context?.setLineWidth(6.0/scale!)
		context?.stroke(rect)
    }

}
