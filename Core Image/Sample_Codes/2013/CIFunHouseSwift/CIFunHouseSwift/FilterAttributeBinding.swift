//
//  FilterAttributeBinding.swift
//  CIFunHouseSwift
//
//  Created by Seyed Samad Gholamzadeh on 8/8/1396 AP.
//  Copyright © 1396 AP Seyed Samad Gholamzadeh. All rights reserved.
//

import Foundation
import CoreImage

let FilterAttributeValueDidUpdateNotification = "FilterAttributeValueDidUpdateNotification"
let FilterAttributeBindingFilterNameKey = "FilterName"
let FilterAttributeBindingAttributeNameKey = "AttributeName"
let FilterAttributeBindingAttributeValueStringKey = "AttributeValueString"

let kFilterObject = "FilterObject"
let kFilterInputValue = "FilterInputValue"
let kFilterInputKey = "FilterInputKey"


class FilterAttributeBinding : NSObject, SliderCellDelegate {
	
	var filter: CIFilter
	var screenSize: CGSize
	var attrName: String
	var attrType: String
	var attrClass: AnyClass?
	var attrDefault: AnyObject
	var sliderCellBindings: [SliderCell: Int]
	
	var minElementValue: CGFloat
	var maxElementValue: CGFloat
	
	var elementCount: Int {
		if attrDefault is NSNumber {
			return 1
		}
		else if attrDefault is CIVector {
			if let attr = attrDefault as? CIVector {
				return attr.count
			}
		}
		else if attrDefault is CIColor {
			return 4
		}
		else if CIFilterIsValueOfTypeCGAffineTransform(attrDefault) {
			return 6
		}
		return 0
	}
	
	var title: String {
		return CIFilterGetShortenedInputAttributeName(attrName)
	}
	
	
	init(filter: CIFilter, name: String, dictionary: [String: Any], screenSize: CGSize) {
		self.filter = filter
		self.attrName = name
		self.screenSize = screenSize
		let className: String = dictionary[kCIAttributeClass] as! String
		
		let aClass: AnyClass? = NSClassFromString(className)
		assert(aClass != nil, "Must have a valid CIAttributeClass: \(String(describing: aClass))")

		self.attrClass = aClass
		
		self.attrDefault = dictionary[kCIAttributeDefault] as AnyObject
		self.attrType = dictionary[kCIAttributeType] as? String ?? ""

//		var number: NSNumber? = nil
		
		if let n = dictionary[kCIAttributeSliderMin] as? Double {
			minElementValue = CGFloat(n)
		}
		else if let n = dictionary[kCIAttributeMin] as? Double {
			minElementValue = CGFloat(n)
		}
		else {
			minElementValue = -5.0
		}
		
		if let n = dictionary[kCIAttributeSliderMax] as? CGFloat {
			maxElementValue = n
		}
		else if let n = dictionary[kCIAttributeMax] as? CGFloat {
			maxElementValue = n
		}
		else {
			maxElementValue = 5.0
		}

		if filter.name == "CICrop" {
			
			// special settings for CICrop
			minElementValue = 0.0
			maxElementValue = FCGetGlobalCropFilterMaxValue()
			
			if let inputRect: CIVector = filter.value(forKey: "inputRectangle") as? CIVector {
				if inputRect.isEqual(attrDefault) {
					let info: [String : Any] = [kFilterObject : filter,
					                            kFilterInputValue : CIVector(x: minElementValue, y: minElementValue, z: maxElementValue, w: maxElementValue),
					                            kFilterInputKey : "inputRectangle"]
					NotificationCenter.default.post(name: NSNotification.Name(FilterAttributeValueDidUpdateNotification), object: nil, userInfo: info)
				}
			}
		}
		else if filter.name == "CITemperatureAndTint" {
			
			// special settings for CITemperatureAndTint
			minElementValue = 0.0
			maxElementValue = 15000.0
		}
		else if filter.name == "CIAffineTransform" {
			
			// special settings for CIAffineTransform
			minElementValue = -CGFloat.pi*2
			maxElementValue = CGFloat.pi*2
		}
		
		sliderCellBindings = [:]
		super.init()
	}
	
	
	
	func titleFor(index: Int) -> String {
		if attrDefault is NSNumber {
			return "Value"
		}
		else if attrDefault is CIVector {
			if let attr = attrDefault as? CIVector {
				if attr.count > 4 {
					let title = String(format: "%lu", arguments: [index])
					return title
				}
				else {
					let xyzw = "XYZW"
					let index = xyzw.index(xyzw.startIndex, offsetBy: index)
					let title = String(xyzw[index])
					return title
				}
			}
		}
		else if attrDefault is CIColor {
			switch (index) {
			case 0: return "R"
			case 1: return "G"
			case 2: return "B"
			case 3: return "A"
			default: return "Invalid"
			}
		}
		else if CIFilterIsValueOfTypeCGAffineTransform(attrDefault) {
			switch (index) {
			case 0: return "a";
			case 1: return "b";
			case 2: return "c";
			case 3: return "d";
			case 4: return "tx";
			case 5: return "ty";
			default: return "Invalid";
			}
		}
		return "Invalid"
	}
	
	func valueFor(index: Int, attribute attr: AnyObject) -> CGFloat? {
		if let attr = attr as? NSNumber {
			return CGFloat(attr.doubleValue)
		}
		else if let attr = attr as? CIVector {
			var value = attr.value(at: index)
			if attrType == kCIAttributeTypePosition {
				if index == 0 {
					value /= screenSize.width
				}
				if index == 1 {
					value /= screenSize.height
				}
			}
			return value
		}
		else if let attr = attrDefault as? CIColor {
			switch (index) {
			case 0: return attr.red
			case 1: return attr.green
			case 2: return attr.blue
			case 3: return attr.alpha
			default: return nil
			}
		}
		else if CIFilterIsValueOfTypeCGAffineTransform(attrDefault) {
			var transform = CGAffineTransform()
			attr.getValue(&transform)
			switch (index) {
			case 0: return transform.a
			case 1: return transform.b
			case 2: return transform.c
			case 3: return transform.d
			case 4: return transform.tx
			case 5: return transform.ty
			default: return nil
			}
		}
		return nil
	}
	
	func defaultValue(for index: Int) -> CGFloat {
		return self.valueFor(index: index, attribute: attrDefault)!
	}
	
	func elementValue(for index: Int) -> CGFloat {
		return self.valueFor(index: index, attribute: filter.value(forKey: attrName) as AnyObject)!
	}

	
	// when a SliderCell is bound to a filter attribute, any value change in the slider will cause change in the bound filter and attribute
	func bind(_ cell: SliderCell, toIndex index: Int) {
		assert(sliderCellBindings[cell] == nil, "Cell must not already be bound")
		sliderCellBindings[cell] = index
	}
	
	func unbind(cell: SliderCell) {
		assert(sliderCellBindings[cell] != nil, "Cell must already be bound")
		sliderCellBindings.removeValue(forKey: cell)
		
	}
	
	// reverts the attribute's value to the default, and also causes the corresponding change in the bound SliderCell
	func revertToDefaultValues() {
		var info: [String: Any] = [kFilterObject: filter, kFilterInputValue: attrDefault, kFilterInputKey: attrName]
		
		if filter.name == "CICrop" {
			info = [kFilterObject : filter,
			        kFilterInputValue : CIVector(x: minElementValue, y: minElementValue, z: maxElementValue, w: maxElementValue),
			        kFilterInputKey : "inputRectangle"]
		}
		
		for (cell, index) in sliderCellBindings {
			cell.slider.value = Float(self.elementValue(for: index))
			cell.slider.sendActions(for: .valueChanged)
		}
		
		NotificationCenter.default.post(name: NSNotification.Name(FilterAttributeValueDidUpdateNotification), object: filter, userInfo: info)

	}
	
	//MARK: - Delegate methods
	
	func sliderCellValueDidChange(cell: SliderCell) {
		guard let index = sliderCellBindings[cell] else {
			fatalError("Slider cell value change must be originated from a binding")
		}
		
		var attrValue: Any?
		
		if attrDefault is NSNumber {
			let value = cell.slider.value
			attrValue = NSNumber(value: value)
		}
		else if attrDefault is CIVector {
			
			var newValue = CGFloat(cell.slider.value)
			if attrType == kCIAttributeTypePosition {
				if index == 0 {
					newValue *= screenSize.width
				}
				if index == 1 {
					newValue *= screenSize.height
				}
			}
			
			if let vOld = filter.value(forKey: attrName) as? CIVector {
				let vCount = vOld.count
				if index >= vCount {
					fatalError("Invalid element index")
				}
//				var vals: Array<CGFloat> = []
				
				let vals = UnsafeMutablePointer<CGFloat>.allocate(capacity: vCount)
				
				for i in 0..<vCount {
					vals[i] = vOld.value(at: i)
				}
				
				vals[index] = newValue
				let vNew = CIVector(values: vals, count: vCount)
				 attrValue = vNew
				free(vals)
			}
		}
		else if attrDefault is CIColor {
			let newValue = CGFloat(cell.slider.value)
			if var color = filter.value(forKey: attrName) as? CIColor {
				var red = color.red
				var green = color.green
				var blue = color.blue
				var alpha = color.alpha
				
				switch (index) {
				case 0: red = newValue
				case 1: green = newValue
				case 2: blue = newValue
				case 3: alpha = newValue
				default:
					fatalError("Invalid element index")
				}
				color = CIColor(red: red, green: green, blue: blue, alpha: alpha)
				attrValue = color
			}
		}
		else if CIFilterIsValueOfTypeCGAffineTransform(attrDefault) {
			let newValue = CGFloat(cell.slider.value)

			var transform = CGAffineTransform()
			(filter.value(forKey: attrName) as AnyObject ).getValue(&transform)
			
			switch (index) {
			case 0: transform.a = newValue
			case 1: transform.b = newValue
			case 2: transform.c = newValue
			case 3: transform.d = newValue
			case 4: transform.tx = newValue
			case 5: transform.ty = newValue
			default:
				fatalError("Invalid element index")
			}
			
			let newTransformValue: NSValue = NSValue(cgAffineTransform: transform)
			attrValue = newTransformValue
		}
		
		if attrValue != nil {
			let info: [String: Any] = [kFilterObject : filter,  kFilterInputValue : attrValue!,  kFilterInputKey : attrName]
			NotificationCenter.default.post(name: NSNotification.Name(FilterAttributeValueDidUpdateNotification), object: filter, userInfo: info)
		}
	}

}
