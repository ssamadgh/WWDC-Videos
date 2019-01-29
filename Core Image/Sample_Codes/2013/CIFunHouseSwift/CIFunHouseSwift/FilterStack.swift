//
//  FilterStack.swift
//  CIFunHouseSwift
//
//  Created by Seyed Samad Gholamzadeh on 8/7/1396 AP.
//  Copyright © 1396 AP Seyed Samad Gholamzadeh. All rights reserved.
//

import Foundation
import CoreImage

let FilterStackActiveFilterListDidChangeNotification = "FilterStackActiveFilterListDidChangeNotification"

let kFilterSettingsKey = "FilterSettings"
let kFilterOrderKey = "FilterOrder"


class FilterDescriptor: NSObject {
	
	var name: String
	var displayName: String
	var inputImageCount: Int
	
	var filter: CIFilter? {
		return CIFilter(name: self.name)
	}
	
	init?(name: String) {
		
		let filter: CIFilter! = CIFilter(name: name)
		
		if filter != nil {
			self.name = name
			self.displayName = filter.attributes[kCIAttributeFilterDisplayName] as! String
			self.inputImageCount = filter.isSourceFilter ? 0 : filter.imageInputCount
			super.init()
		}
		else {
			return nil
		}
	}
	
}

class SourceFilter: CIFilter {
	
	class func register() {
		CIFilter.registerName("SourceVideoFilter", constructor: SourceFilterGenerator())
		CIFilter.registerName("SourcePhotoFilter", constructor: SourceFilterGenerator())
	}

	@objc dynamic var inputImage: CIImage?

	override var outputImage: CIImage? {
		return inputImage ?? CIImage.empty()
	}
}

class SourceFilterGenerator: NSObject, CIFilterConstructor {
	
	@objc func filter(withName name: String) -> CIFilter? {
		switch name {
		case "SourceVideoFilter":
			return SourceVideoFilter()
		case "SourcePhotoFilter":
			return SourcePhotoFilter()
		default: return nil

		}
	}
}

class SourceVideoFilter : SourceFilter {
	
	override var attributes: [String : Any] {
				var costumAttr = super.attributes
				costumAttr[kCIAttributeFilterDisplayName] = "Input Video"
				costumAttr[kCIAttributeFilterCategories] = [kCICategoryVideo]
				costumAttr[kCIAttributeFilterName] = "SourceVideoFilter"

		return costumAttr
	}
	
}

class SourcePhotoFilter : SourceFilter {
	
	override var attributes: [String : Any] {
		var costumAttr = super.attributes
		costumAttr[kCIAttributeFilterDisplayName] = "Input Photo"
		costumAttr[kCIAttributeFilterCategories] = [kCICategoryStillImage]
		costumAttr[kCIAttributeFilterName] = "SourcePhotoFilter"

		return costumAttr
	}
}

class FilterStack: NSObject {
	
	var activeFilters: Array<CIFilter>
	var possibleNextFilters: Array<FilterDescriptor>
	var sources: Array<FilterDescriptor>
	var nonsources: Array<FilterDescriptor>
	var sourceCount: Int
	
	var containsPhotoSource: Bool {
		for filter in activeFilters {
			if filter is SourcePhotoFilter {
				return true
			}
		}
		return false
	}
	
	var containsVideoSource: Bool {
		for filter in activeFilters {
			if filter is SourceVideoFilter {
				return true
			}
		}
		return false
	}

	
	override init() {
		
		self.sourceCount = 0
		self.activeFilters = []
		self.sources = []
		self.nonsources = []
		self.possibleNextFilters = []
		super.init()
		
		var descriptor: FilterDescriptor
		
		SourceFilter.register()
		
		let video = FilterDescriptor(name: "SourceVideoFilter")
		sources.append(video!)
		
		let image = FilterDescriptor(name: "SourcePhotoFilter")
		sources.append(image!)
		
		for name in CIFilter.filterNames(inCategory: kCICategoryBuiltIn) {
			guard let filter = CIFilter(name: name) else {
				continue
			}
			guard filter.isUsableFilter else {
				continue
			}
			descriptor = FilterDescriptor(name: name)!
			
			if filter.imageInputCount == 0 {
				sources.append(descriptor)
			}
			else {
				nonsources.append(descriptor)
			}
		}
		
		// Add in custom filters here:
//		let customFilters = [ "ChromaKey",
//		                      "ColorAccent",
//		                      "PixellatedPeople",
//		                      "TiltShift",
//		                      "OldeFilm",
//		                      "PixellateTransition",
//		                      "DistortionDemo",
//		                      "SobelEdgeH",
//		                      "SobelEdgeV"]
//		for filter in customFilters {
//			descriptor = FilterDescriptor(name: filter)!
//			nonsources.append(descriptor)
//		}
	}
	
	func updateFilterList() {
		// Update sourceCount to reflect the number of active sources - i.e,
		// the number of filters that can be used as inputs to new filters
		var sourceCount = 0
		
		for filter in self.activeFilters {
			for _ in filter.imageInputAttributeKeys {
				if !filter.isSourceFilter {
					if sourceCount > 0 {
						sourceCount -= 1
					}
				}
			}
			sourceCount += 1
		}
		
		let prevSourceCount = self.sourceCount
		self.sourceCount = sourceCount
		
		if sourceCount != prevSourceCount {
			var newset: [FilterDescriptor] = []
			for descriptor in nonsources {
				if descriptor.inputImageCount <= sourceCount {
					newset.append(descriptor)
				}
			}
			possibleNextFilters = newset
		}
		
		NotificationCenter.default.post(name: NSNotification.Name(FilterStackActiveFilterListDidChangeNotification), object: self)
	}
	
	
	func append(_ filter: CIFilter) {
		self.activeFilters.append(filter)
		self.updateFilterList()
	}
	
	func removeLastFilter() {
		if !activeFilters.isEmpty {
			activeFilters.removeLast()
			self.updateFilterList()
		}
	}
}

var gFSGlobalCropFilterMaxValue: CGFloat = CGFloat.infinity

func FCSetGlobalCropFilterMaxValue(_ max: CGFloat) {
	gFSGlobalCropFilterMaxValue = max
}
func FCGetGlobalCropFilterMaxValue() -> CGFloat {
	return gFSGlobalCropFilterMaxValue
}
