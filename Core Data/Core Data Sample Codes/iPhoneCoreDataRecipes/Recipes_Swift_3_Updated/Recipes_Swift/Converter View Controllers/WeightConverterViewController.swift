/*
  WeightConverterViewController.swift
  Recipes_Swift

  Created by Seyed Samad Gholamzadeh on 2/28/18.
  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.

Abstract:
View controller to manage conversion of metric to imperial units of weight and vice versa.
The controller uses two UIPicker objects to allow the user to select the weight in metric or imperial units.
*/


import UIKit

class WeightConverterViewController: UIViewController {

	@IBOutlet weak var pickerViewContainer: UIView!
	@IBOutlet weak var metricPickerController: MetricPickerController!
	@IBOutlet weak var metricPickerViewContainer: UIView!
	@IBOutlet weak var imperialPickerController: ImperialPickerController!
	@IBOutlet weak var imperialPickerViewContainer: UIView!
	@IBOutlet weak var segmentedControl: UISegmentedControl!
	
	var selectedUnit: Int!

	enum Index: Int {
		case metric, imperial
	}

    override func viewDidLoad() {
        super.viewDidLoad()

		// Set the currently-selected unit for self and the segmented control.
		self.selectedUnit = Index.metric.rawValue
		self.segmentedControl.selectedSegmentIndex = self.selectedUnit
		self.toggleUnit()
    }
	
	@IBAction func toggleUnit() {
		
		/*
		When the user changes the selection in the segmented control, set the appropriate picker as the current subview of the picker container view (and remove the previous one).
		*/
		self.selectedUnit = self.segmentedControl.selectedSegmentIndex
		
		if self.selectedUnit == Index.imperial.rawValue {
			self.metricPickerViewContainer.removeFromSuperview()
			self.pickerViewContainer.addSubview(self.imperialPickerViewContainer)
			self.imperialPickerController.updateLabel()
		}
		else {
			self.imperialPickerViewContainer.removeFromSuperview()
			self.pickerViewContainer.addSubview(self.metricPickerViewContainer)
			self.metricPickerController.updateLabel()
		}

	}
	
}
