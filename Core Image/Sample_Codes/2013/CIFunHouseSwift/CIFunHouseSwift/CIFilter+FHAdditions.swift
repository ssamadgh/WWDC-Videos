//
//  CIFilter+FHAdditions.swift
//  CIFunHouseSwift
//
//  Created by Seyed Samad Gholamzadeh on 8/7/1396 AP.
//  Copyright © 1396 AP Seyed Samad Gholamzadeh. All rights reserved.
//

import Foundation
import CoreImage

extension CIFilter {
	
	var imageInputAttributeKeys: [String] {

		// cache the enumerated image input attributes
		let associationKey = "_storedImageInputAttributeKeys"
		var attributes: [String] = objc_getAssociatedObject(self, associationKey) as? [String] ?? []
		
		if attributes.isEmpty {
			var addingArray: [String] = []
			for key in self.inputKeys {
				let attrDict: [String: Any]? = self.attributes[key] as? [String : Any]
				if let element = attrDict?[kCIAttributeType] as? String {
					if element == kCIAttributeTypeImage {
						addingArray.append(key)
					}
				}
			}
			attributes = addingArray
			objc_setAssociatedObject(self, associationKey, attributes, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
		}
		
		return attributes
	}
	
	var imageInputCount: Int {
		return self.imageInputAttributeKeys.count
	}
	
	var onlyRequiresInputImages: Bool {
		return self.imageInputCount == self.inputKeys.count
	}
	
	var isUsableFilter: Bool {
		// for now only CIColorCube is not usable
		return self.name != "CIColorCube"
	}
	
	var isSourceFilter: Bool {
		return self is SourceFilter
	}
	
	static func isAttributeConfigurable(filterAttributeDictionary: [String: Any]) -> Bool {
		let names: [String] = ["CIColor", "CIVector", "NSNumber"]
		
		if names.contains(filterAttributeDictionary[kCIAttributeClass] as! String) {
			return true
		}
				
		if let attrType = filterAttributeDictionary[kCIAttributeType] as? String,
			attrType == kCIAttributeTypeTransform {
			return true
		}
		return false
	}
	
}

func CIFilterGetShortenedInputAttributeName(_ name: String) -> String {
	return name.hasPrefix("input") ? {
		let index = name.index(name.startIndex, offsetBy: 5)
		let result = name[index...]
		return "\(result)"
		}() : name
}

func CIFilterIsValueOfTypeCGAffineTransform(_ value: AnyObject) -> Bool {

	return value is NSValue && strcmp(value.objCType, NSValue(cgAffineTransform: CGAffineTransform.identity).objCType) != 0
}






