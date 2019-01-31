/*
  MetricPickerController.swift
  Recipes_Swift

  Created by Seyed Samad Gholamzadeh on 2/28/18.
  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.

Abstract:
Controller to managed a picker view displaying metric weights.
*/


import UIKit

var roundingBehavior: NSDecimalNumberHandler? = nil

class MetricPickerController: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {

	@IBOutlet weak var pickerView: UIPickerView!
	@IBOutlet weak var label: UILabel!


	// Identifiers and widths for the various components.
	enum KG: Int {
		case component = 0, componentWidth = 88, labelWidth = 46
	}
	
	enum G0: Int {
		case component = 3, componentWidth = 74, labelWidth = 44
	}

	enum G: Int {
		case componentWidth = 50
	}
	
	// Identifies for component views.
	enum Tag: Int {
		case view = 41, subLabel, label
	}

	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		return 4
	}
	
	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		
		// Number of rows depends on the currently-selected unit and the component.
		if (component == KG.component.rawValue) {
			return 20;
		}
		// OUNCES_LABEL_COMPONENT
		return 10;
	}
	
	func labelCellWith( width: CGFloat, rightOffset offset: CGFloat) -> UIView {
		
		// Create a new view that contains a label offset from the right.
		var frame = CGRect(origin: .zero, size: CGSize(width: width, height: 32.0))
		let view = UIView(frame: frame)
		view.tag = Tag.view.rawValue
		
		frame.size.width = width - offset
		let sublabel = UILabel(frame: frame)
		sublabel.textAlignment = .right
		sublabel.backgroundColor = UIColor.clear
		sublabel.font = UIFont.systemFont(ofSize: 24.0)
		
		sublabel.tag = Tag.subLabel.rawValue
		
		view.addSubview(sublabel)
		return view
	}
	
	
	func viewFor(component: Int) -> UIView {
		
		
		/*
		Return a view appropriate for the specified picker view and component.
		If it's the picker view, or if it's the kg or g component of the metric view, create a UIView that contains a label.  The label can then be offset in the containing view so that its text does not overlap the unit symbol.
		For the remaining components, simple create a label to contain the text.
		Give all the views tags so they can be idntified easily.
		*/
		if component == KG.component.rawValue {
			return self.labelCellWith(width: CGFloat(KG.componentWidth.rawValue), rightOffset: CGFloat(KG.labelWidth.rawValue))
		}

		if component == G0.component.rawValue {
			return self.labelCellWith(width: CGFloat(G0.componentWidth.rawValue), rightOffset: CGFloat(G0.labelWidth.rawValue))
		}
		
		let frame = CGRect(origin: .zero, size: CGSize(width: 36.0, height: 32.0))
		let aLabel = UILabel(frame: frame)
		aLabel.textAlignment = .center
		aLabel.backgroundColor = UIColor.clear
		aLabel.font = UIFont.systemFont(ofSize: 24.0)
		aLabel.isUserInteractionEnabled = false
		aLabel.tag = Tag.label.rawValue
		return aLabel
	}
	
	func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
		
		var returnView: UIView? = nil
		
		// Reuse the label if possible, otherwise create and configure a new one.
		if view?.tag == Tag.view.rawValue || view?.tag == Tag.label.rawValue {
			returnView = view
		}
		else {
			returnView = self.viewFor(component: component)
		}
		
		// The text shown in the component is just the number of the component.
		let text = "\(row)"
		
		// Where to set the text in depends on what sort of view it is.
		var theLabel: UILabel? = nil
		if returnView?.tag == Tag.view.rawValue {
			theLabel = returnView?.viewWithTag(Tag.subLabel.rawValue) as? UILabel
		}
		else {
			theLabel = returnView as? UILabel
		}
		
		theLabel?.text = text
		return returnView!
	}
	
	func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
		
		// The width of the component depends on the currently-selected unit and the component.
		
		if component == KG.component.rawValue {
			return CGFloat(KG.componentWidth.rawValue)
		}
		if component == G0.component.rawValue {
			return CGFloat(KG.componentWidth.rawValue)
		}
		return CGFloat(G.componentWidth.rawValue)
	}

	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		
		// If the user chooses a new row, update the label accordingly.
		self.updateLabel()
	}

	
	func updateLabel() {
		
		/*
		If the user has entered metric units, find the number of grams and convert that to pounds and ounces.
		Don't display 0 lbs; round 15.95 ounces up to 1 lb, and use NSDecimalNumberHandler to round ounces for a more attractive display.
		*/
		
		if roundingBehavior == nil {
			roundingBehavior = NSDecimalNumberHandler(roundingMode: NSDecimalNumber.RoundingMode.plain,
								  scale: 1, raiseOnExactness: false,
								  raiseOnOverflow: false,
								  raiseOnUnderflow: false,
								  raiseOnDivideByZero: false)
		}

		var grams: Int = 0
		grams += self.pickerView.selectedRow(inComponent: 3)
		grams += self.pickerView.selectedRow(inComponent: 2) * 10
		grams += self.pickerView.selectedRow(inComponent: 1) * 100
		grams += self.pickerView.selectedRow(inComponent: 0) * 1000

		var ouncesDecimal: NSDecimalNumber!
		var roundedOunces: NSDecimalNumber!
		
		var ounces: Double = Double(grams)/28.349

		if ounces >= 15.95 {
			var lbs: Int = Int(ounces / 16)
			ounces -= Double(lbs)*16
			if ounces >= 15.95 {
				ounces = 0
				lbs += 1
			}
			ouncesDecimal = NSDecimalNumber(value: ounces)
			roundedOunces = ouncesDecimal.rounding(accordingToBehavior: roundingBehavior)
			self.label.text = "\(lbs) lbs \(roundedOunces!) oz"
		}
		else {
			ouncesDecimal = NSDecimalNumber(value: ounces)
			roundedOunces = ouncesDecimal.rounding(accordingToBehavior: roundingBehavior)
			self.label.text = "\(roundedOunces!) oz"
		}

	}

	
}
