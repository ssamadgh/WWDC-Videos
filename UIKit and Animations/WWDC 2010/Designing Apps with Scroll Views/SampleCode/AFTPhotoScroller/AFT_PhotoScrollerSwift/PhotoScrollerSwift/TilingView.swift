//
//  TilingView.swift
//  FrogsDemoSwift
//
//  Created by Seyed Samad Gholamzadeh on 10/3/1396 AP.
//  Copyright © 1396 AP Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit
import QuartzCore

class TilingView: UIView {
	
	var imageName: String!
	var annotates: Bool = true
	
	override class var layerClass: AnyClass {
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
	
	init(imageName: String, size: CGSize) {
		self.imageName = imageName
		super.init(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
		tiledLayer.levelsOfDetail = 4
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	
    override func draw(_ rect: CGRect) {

		let context = UIGraphicsGetCurrentContext()!

		// get the scale from the context by getting the current transform matrix, then asking
		// for its "a" component, which is one of the two scale components. We could also ask
		// for "d". This assumes (safely) that the view is being scaled equally in both dimensions.
		let scale: CGFloat = context.ctm.a

		var tileSize = tiledLayer.tileSize
		
		// Even at scales lower than 100%, we are drawing into a rect in the coordinate system
		// of the full image. One tile at 50% covers the width (in original image coordinates)
		// of two tiles at 100%. So at 50% we need to stretch our tiles to double the width
		// and height; at 25% we need to stretch them to quadruple the width and height; and so on.
		// (Note that this means that we are drawing very blurry images as the scale gets low.
		// At 12.5%, our lowest scale, we are stretching about 6 small tiles to fill the entire
		// original image area. But this is okay, because the big blurry image we're drawing
		// here will be scaled way down before it is displayed.)
		tileSize.width /= scale
		tileSize.height /= scale
		
		// calculate the rows and columns of tiles that intersect the rect we have been asked to draw
		let firstCol: Int = Int(floor(rect.minX/tileSize.width))
		let lastCol: Int = Int(floor((rect.maxX-1)/tileSize.width))
		let firstRow: Int = Int(floor(rect.minY/tileSize.height))
		let lastRow: Int = Int(floor((rect.maxY-1)/tileSize.height))
		
		for row in firstRow...lastRow {
			for col in firstCol...lastCol {
				let tile = tileFor(scale: scale, row: row, col: col)
				var tileRect = CGRect(x: tileSize.width*CGFloat(col), y: tileSize.height*CGFloat(row), width: tileSize.width, height: tileSize.height)
				
				// if the tile would stick outside of our bounds, we need to truncate it so as
				// to avoid stretching out the partial tiles at the right and bottom edges
				tileRect = self.bounds.intersection(tileRect)
				tile.draw(in: tileRect)
				
				if annotates {
					UIColor.white.set()
					context.setLineWidth(6.0/scale)
					context.stroke(tileRect)
				}
			}
		}

    }
	
	
	func tileFor(scale: CGFloat, row: Int, col: Int) -> UIImage {
		// we use "imageWithContentsOfFile:" instead of "imageNamed:" here because we don't
		// want UIImage to cache our tiles
		//
		let tileName = "\(self.imageName!)_\(Int(scale*1000))_\(col)_\(row)"
		let path = Bundle.main.path(forResource: tileName, ofType: "png")!
		let image = UIImage(contentsOfFile: path)!
		return image
	}
	
}
