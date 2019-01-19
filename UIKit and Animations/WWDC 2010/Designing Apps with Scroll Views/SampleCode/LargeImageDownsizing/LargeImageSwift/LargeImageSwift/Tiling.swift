//
//  Tiling.swift
//  LargeImageSwift
//
//  Created by Seyed Samad Gholamzadeh on 1/12/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import Foundation
import UIKit


func makeTiles(for image: UIImage, to directoryURL: URL, usingPrefix prefix: String, completion: (Bool) -> ()) {
	var scale: CGFloat = 0.125
	while scale <= 1 {
		saveTiles(for: image, inScale: scale, to: directoryURL, usingPrefix: prefix) { (finished) in
			if !finished {
				completion(finished)
				return
			}
			scale *= 2
		}
	}
}
func saveTiles( of size: CGSize = CGSize(width: 256.0, height: 256.0), for image: UIImage, inScale scale: CGFloat, to directoryURL: URL, usingPrefix prefix: String, completion: (Bool) -> ()) {
	
	var image = image
	
	let imageWidth = CGFloat(image.cgImage!.width)
	let imageHeight = CGFloat(image.cgImage!.height)

	// Create a low res image representation of the image to display before the TiledImageView
	// renders its content.
	let imageRect = CGRect(origin: .zero, size: CGSize(width: imageWidth*scale, height: imageHeight*scale))

	if scale != 1 {
		UIGraphicsBeginImageContext(imageRect.size)
		let context = UIGraphicsGetCurrentContext()
		
		context?.saveGState()
		context?.translateBy(x: 0, y: imageRect.height)
		context?.scaleBy(x: 1, y: -1)

		context?.draw(image.cgImage!, in: imageRect)
		context?.restoreGState()
		image = UIGraphicsGetImageFromCurrentImageContext()!
		UIGraphicsEndImageContext()
	}
	
	let cols = imageRect.width/size.width
	let rows = imageRect.height/size.height
	
	var fullColomns = floor(cols)
	var fullRows = floor(rows)
	
	let remainderWidth = imageRect.width - fullColomns*size.width
	let remainderHeight = imageRect.height - fullRows*size.height
	
	if cols > fullColomns { fullColomns += 1 }
	if rows > fullRows { fullRows += 1 }
	
	let fullImage = image.cgImage!

	for row in 0..<Int(fullRows) {
		for col in 0..<Int(fullColomns ){
			var tileSize = size
			if col + 1 == Int(fullColomns) && remainderWidth > 0 {
				// Last Column
				tileSize.width = remainderWidth
			}
			if row + 1 == Int(fullRows) && remainderHeight > 0 {
				// Last Row
				tileSize.height = remainderHeight
			}
			
			let tileImage = fullImage.cropping(to: CGRect(origin: CGPoint(x: CGFloat(col)*size.width, y: CGFloat(row)*size.height), size: tileSize))!
			let imageData = UIImagePNGRepresentation(UIImage(cgImage: tileImage))
			
			let tileName = "\(prefix)_\(Int(scale*1000))_\(col)_\(row).png"
			let url = directoryURL.appendingPathComponent(tileName)
			do {
				try imageData!.write(to: url)
			}
			catch {
				print(error)
				let finished = false
				completion(finished)
				break
			}
		}
	}
	
	let finished = true
	completion(finished)

}

