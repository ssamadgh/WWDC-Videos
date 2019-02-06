/*
  ImperialPickerController.swift
  Recipes_Swift

  Created by Seyed Samad Gholamzadeh on 2/28/18.
  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.

Abstract:
Controller to managed a picker view displaying imperial weights.
*/


import UIKit

class ImperialPickerController: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {

	@IBOutlet weak var pickerView: UIPickerView!
	@IBOutlet weak var label: UILabel!

	
	// Identifiers and widths for the various components.
	enum Pounds: Int {
		case component = 0, componentWidth = 110, labelWidth = 60
	}
	
	enum Ounces: Int {
		case component = 1, componentWidth = 106, labelWidth = 56
	}
	
	// Identifies for component views.
	enum Tag: Int {
		case view = 41, subLabel, label
	}

	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		return 2
	}
	
	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		
		// Number of rows depends on the currently-selected unit and the component.
		if (component == Pounds.component.rawValue) {
			return 29;
		}
		// OUNCES_LABEL_COMPONENT
		return 16;
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
	
	func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
		
		var returnView: UIView? = nil

		// Reuse the label if possible, otherwise create and configure a new one.
		if view?.tag == Tag.view.rawValue || view?.tag == Tag.label.rawValue {
			returnView = view
		}
		else {
			if component == Pounds.component.rawValue {
				returnView = self.labelCellWith(width: CGFloat(Pounds.componentWidth.rawValue), rightOffset: CGFloat(Pounds.labelWidth.rawValue))
			}
			else {
				returnView = self.labelCellWith(width: CGFloat(Ounces.componentWidth.rawValue), rightOffset: CGFloat(Ounces.labelWidth.rawValue))
			}
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
		
		if component == Pounds.component.rawValue {
			return CGFloat(Pounds.componentWidth.rawValue)
		}
		// OUNCES_COMPONENT
		return CGFloat(Ounces.componentWidth.rawValue)
	}
	
	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		
		// If the user chooses a new row, update the label accordingly.
		self.updateLabel()
	}
	
	func updateLabel() {
		
		/*
		If the user has entered imperial units, find the number of pounds and ounces and convert that to kilograms and grams.
		Don't display 0 kg.
		*/
		var ounces = self.pickerView.selectedRow(inComponent: Ounces.component.rawValue)
		ounces += self.pickerView.selectedRow(inComponent: Pounds.component.rawValue*16)
		
		var grams: Double = Double(ounces)*28.349
		if grams > 1000.0 {
			let kg = Int(grams/1000)
			grams -= Double(kg*1000)
			self.label.text = "\(kg) kg \(grams) g"
		}
		else {
			self.label.text = "\(grams) g"
		}
	}
}
