//
//  ImageBrowserOptions.swift
//  ImageBrowser
//
//  Created by Seyed Samad Gholamzadeh on 2/2/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//


/*
	When set to "true", ImageBrowserItemLayer defers image loading to a
	background thread instead of loading images on the main thread the
	first time they're needed.
*/
let useImageThread: Bool = true


/*
	When set to "true", use the shadowPath property to define shadows.
*/
let useShadowPath: Bool = true


/*
	When set to "true", ImageBrowserItemLayer draws each image into its
	backing store, i.e. shrinks the image to its displayed size, rather
	than setting the image directly as its contents property. In this
	mode shadows are drawn into the layer's backing store using Core
	Graphics instead of using the CALayer shadows.
*/
let downSampleImages: Bool = true


/*
	When set to "true", ImageBrowserView sets the opaque property of each
	itemView to "true". Only has an effect when downSampleImages = true.
*/
let isOpaqueItemViews: Bool = true


/*
	When set non-zero, the scroller will progressively fade out its top
	and bottom edges. When set to "1", does that setting the CALayer
	`mask` property to a view containing two gradient layers, when set
	to "2", does that by compositing two gradient layers over the
	scroller contents.
*/
let softScrollerEdges: Int = 2

/*
	When set to "true", ImageBrowserView do not load all images in memory and uses the benefit of tiling
*/
let useTiling: Bool = true
