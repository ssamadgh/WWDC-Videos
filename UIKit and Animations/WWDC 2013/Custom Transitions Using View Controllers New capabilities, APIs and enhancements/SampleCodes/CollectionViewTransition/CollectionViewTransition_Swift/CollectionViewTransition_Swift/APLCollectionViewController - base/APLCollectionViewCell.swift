//
//  APLCollectionViewCell.swift
//  CollectionViewTransition_Swift
//
//  Created by Seyed Samad Gholamzadeh on 6/30/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.

//  Abstract: The custom UICollectionViewCell containing a single UIImageView.


import UIKit

class APLCollectionViewCell: UICollectionViewCell {
	
	var imageView: UIImageView!
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		// create our image view so that is matches the height and width of this cell
		self.imageView = UIImageView(frame: self.bounds)
		self.imageView.autoresizingMask = UIViewAutoresizing(rawValue: UIViewAutoresizing.flexibleHeight.rawValue | UIViewAutoresizing.flexibleWidth.rawValue)
		self.imageView.contentMode = UIViewContentMode.scaleAspectFill
		self.imageView.clipsToBounds = true

		// add a white frame around the image
		self.imageView.layer.borderWidth = 3.0
		self.imageView.layer.borderColor = UIColor.white.cgColor
		
		// Define how the edges of the layer are rasterized for each of the four edges
		// (left, right, bottom, top) if the corresponding bit is set the edge will be antialiased
		//
		self.imageView.layer.edgeAntialiasingMask = CAEdgeAntialiasingMask(rawValue: CAEdgeAntialiasingMask.layerLeftEdge.rawValue | CAEdgeAntialiasingMask.layerTopEdge.rawValue | CAEdgeAntialiasingMask.layerBottomEdge.rawValue | CAEdgeAntialiasingMask.layerLeftEdge.rawValue)
		
		self.contentView.addSubview(self.imageView)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
