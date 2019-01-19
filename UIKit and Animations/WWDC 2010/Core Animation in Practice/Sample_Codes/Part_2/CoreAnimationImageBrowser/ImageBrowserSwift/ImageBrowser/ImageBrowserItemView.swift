//
//  ImageBrowserItemView.swift
//  ImageBrowser
//
//  Created by Seyed Samad Gholamzadeh on 2/2/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

struct Index: Equatable, Comparable {
	
	let row: Int
	let column: Int
}

func ==(left: Index, right: Index) -> Bool {
	return left.row == right.row && left.column == right.column
}
func <(left: Index, right: Index) -> Bool {
	return left.row < right.row && left.column < right.column
}


class ImageBrowserItemView: UIView {
	
	var index: Int!
	
	var imageURL: URL {
		return itemLayer.imageURL
	}
	
	override class var layerClass: AnyClass {
		return ImageBrowserItemLayer.self
	}
	
	var itemLayer: ImageBrowserItemLayer {
		return self.layer as! ImageBrowserItemLayer
	}

	init(frame: CGRect, imageURL: URL) {
		super.init(frame: frame)
		itemLayer.imageURL = imageURL
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	static func itemViewWith(_ frame: CGRect, imageURL: URL) -> ImageBrowserItemView {
		return ImageBrowserItemView(frame: frame, imageURL: imageURL)
	}

}
