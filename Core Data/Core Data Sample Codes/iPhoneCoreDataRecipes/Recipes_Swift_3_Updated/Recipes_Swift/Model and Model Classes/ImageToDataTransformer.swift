//
//  ImageToDataTransformer.swift
//  Recipes_Swift
//
//  Created by Seyed Samad Gholamzadeh on 1/26/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import Foundation
import UIKit

class ImageToDataTransformer: ValueTransformer {
	
	override class func allowsReverseTransformation() -> Bool {
		return true
	}
	
	override class func transformedValueClass() -> Swift.AnyClass {
		return NSData.self
	}
	
	override func transformedValue(_ value: Any?) -> Any? {
		let data = UIImagePNGRepresentation(value as! UIImage)
		return data
	}
	
	override func reverseTransformedValue(_ value: Any?) -> Any? {
		let image = UIImage(data: value as! Data)
		return image
	}
}
