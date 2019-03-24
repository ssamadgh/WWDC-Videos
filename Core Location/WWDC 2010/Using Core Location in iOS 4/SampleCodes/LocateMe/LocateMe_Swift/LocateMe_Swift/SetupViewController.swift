//
//  ViewController.swift
//  LocateMe_Swift
//
//  Created by Seyed Samad Gholamzadeh on 3/7/19.
//  Copyright © 2019 Seyed Samad Gholamzadeh. All rights reserved.
//

/*
Abstract:

Displayed by either a GetLocationViewController or a TrackLocationViewController, this view controller is presented modally and communicates back to the presenting controller using a simple delegate protocol. The protocol sends setupViewController:didFinishSetupWithInfo: to its delegate with a dictionary containing a desired accuracy and either a timeout or a distance filter value. A custom UIPickerView specifies the desired accuracy. A slider is shown for setting the timeout or distance filter. This view controller can be initialized using either of two nib files: GetLocationSetupView.xib or TrackLocationSetupView.xib. These nibs have nearly identical layouts, but differ in the labels and attributes for the slider.

*/

import UIKit
import CoreLocation

// Keys for the dictionary provided to the delegate.
let kSetupInfoKeyAccuracy: String = "SetupInfoKeyAccuracy"
let kSetupInfoKeyDistanceFilter: String = "SetupInfoKeyDistanceFilter"
let kSetupInfoKeyTimeout: String = "SetupInfoKeyTimeout"

let kAccuracyNameKey: String = "AccuracyNameKey"
let kAccuracyValueKey: String = "AccuracyValueKey"

protocol SetupViewControllerDelegate: class {
	func setupViewController(_ controller: SetupViewController, didFinishSetupWithInfo setupInfo: [String:Any])
}

class SetupViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

	var delegate: SetupViewControllerDelegate?
	
	var setupInfo: [String:Any]!
	var accuracyOptions: [[String:Any]]!
	var configureForTracking: Bool = false
	@IBOutlet weak var accuracyPicker: UIPickerView!
	@IBOutlet weak var slider: UISlider!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		
		var options = [[String:Any]]()
		options.append([kAccuracyNameKey: NSLocalizedString("AccuracyBest", comment: "AccuracyBest"), kAccuracyValueKey: kCLLocationAccuracyBest])
		options.append([kAccuracyNameKey: NSLocalizedString("Accuracy10", comment: "Accuracy10"), kAccuracyValueKey: kCLLocationAccuracyNearestTenMeters])
		options.append([kAccuracyNameKey: NSLocalizedString("Accuracy100", comment: "Accuracy100"), kAccuracyValueKey: kCLLocationAccuracyHundredMeters])
		options.append([kAccuracyNameKey: NSLocalizedString("Accuracy1000", comment: "Accuracy1000"), kAccuracyValueKey: kCLLocationAccuracyKilometer])
		options.append([kAccuracyNameKey: NSLocalizedString("Accuracy3000", comment: "Accuracy3000"), kAccuracyValueKey: kCLLocationAccuracyThreeKilometers])
		self.accuracyOptions = options
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		self.accuracyPicker.selectRow(2, inComponent: 0, animated: false)
		self.setupInfo = [:]
		self.setupInfo[kSetupInfoKeyDistanceFilter] = 100.0
		self.setupInfo[kSetupInfoKeyTimeout] = 30.0;
		self.setupInfo[kSetupInfoKeyAccuracy] = kCLLocationAccuracyHundredMeters
	}
	
	//MARK: - Actions
	
	@IBAction func done(_ sender: Any) {
		self.dismiss(animated: true, completion: nil)
		self.delegate?.setupViewController(self, didFinishSetupWithInfo: self.setupInfo)
	}
	
	@IBAction func sliderChangedValue(_ sender: UISlider) {
		if self.configureForTracking {
			self.setupInfo[kSetupInfoKeyDistanceFilter] = pow(10, sender.value)
		}
		else {
			self.setupInfo[kSetupInfoKeyTimeout] = TimeInterval(exactly: sender.value)
		}
	}
	
	//MARK: - UIPickerViewDataSource
	
	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		return 1
	}
	
	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		return 5
	}
	
	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		let optionForRow = self.accuracyOptions[row]
		return optionForRow[kAccuracyNameKey] as? String
	}
	
	//MARK: - UIPickerViewDelegate
	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		let optionForRow = self.accuracyOptions[row]
		self.setupInfo[kSetupInfoKeyAccuracy] = optionForRow[kAccuracyValueKey]
	}

}

