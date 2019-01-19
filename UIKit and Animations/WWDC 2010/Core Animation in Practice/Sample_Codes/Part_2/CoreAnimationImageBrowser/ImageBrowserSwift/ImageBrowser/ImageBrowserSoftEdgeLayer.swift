//
//  ImageBrowserSoftEdgeLayer.swift
//  ImageBrowser
//
//  Created by Seyed Samad Gholamzadeh on 2/2/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

private let edgeSize: CGFloat = 100

class ImageBrowserSoftEdgeLayer: CALayer {
	
	
	override func layoutSublayers() {
		
		/* When the layer is being used as a mask the alpha at the edge of the
		layer should be zero and one in the middle. When the layer is
		composited over the scroller the alpha should be one at the edge
		and zero in the middle (in which case we only need the two edge
		layers, not the 'middle' layer as well). */
		
		let invertAlpha = self.superlayer?.mask == self
		
		var topEdge: CAGradientLayer? = nil
		var bottomEdge: CAGradientLayer? = nil
		var middle: CALayer? = nil
		
		CATransaction.begin()
		CATransaction.setDisableActions(true)
		
		if self.sublayers != nil, !self.sublayers!.isEmpty {
			
			topEdge = self.sublayers?[0] as? CAGradientLayer
			bottomEdge = self.sublayers?[1] as? CAGradientLayer
			middle = invertAlpha ? self.sublayers?[2] : nil
		}
		else {

			/* We're assuming in the non-masking case (invert_alpha = YES)
			that the backdrop created by our superlayer is white. So
			create a white gradient whose alpha varies from opaque to
			transparent, with the opaque edge aligned to the inside of the
			layer. In the case where this layer is being used to mask the
			backdrop (invert_alpha = NO) only the alpha values we create
			are relevant, and in that case we want the opaque gradient
			edge to be on the inside, so that only the edges are masked
			out. */
			
			let colors: [CGColor] = [UIColor.white.cgColor, UIColor(white: 1, alpha: 0).cgColor]
			
			let axis0 = CGPoint(x: 0.5, y: 0.0)
			let axis1 = CGPoint(x: 0.5, y: 1.0)
			
			topEdge = CAGradientLayer()
			topEdge?.colors = colors
			topEdge?.startPoint = !invertAlpha ? axis0 : axis1
			topEdge?.endPoint = !invertAlpha ? axis1 : axis0
			
			bottomEdge = CAGradientLayer()
			bottomEdge?.colors = colors
			bottomEdge?.startPoint = !invertAlpha ? axis1 : axis0
			bottomEdge?.endPoint = !invertAlpha ? axis0 : axis1
			
			if invertAlpha {
				middle = CALayer()
				middle?.backgroundColor = UIColor.white.cgColor
			}
			
			self.sublayers = invertAlpha ? [topEdge!, bottomEdge!, middle!] : [topEdge!, bottomEdge!]
		}
		
		let bounds = self.bounds
		topEdge?.frame = CGRect(x: bounds.origin.x, y: bounds.origin.y, width: bounds.size.width, height: edgeSize)
		bottomEdge?.frame = CGRect(x: bounds.origin.x, y: bounds.origin.y + bounds.size.height - edgeSize, width: bounds.size.width, height: edgeSize)
		
		if invertAlpha {
			middle?.frame = bounds.insetBy(dx: 0, dy: edgeSize)
		}
		
		self.masksToBounds = true
		
		CATransaction.commit()

		
	}
}








