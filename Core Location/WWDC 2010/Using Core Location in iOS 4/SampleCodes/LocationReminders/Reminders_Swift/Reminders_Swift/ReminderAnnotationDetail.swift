//
//  ReminderAnnotationDetail.swift
//  Reminders_Swift
//
//  Created by Seyed Samad Gholamzadeh on 3/19/19.
//  Copyright © 2019 Seyed Samad Gholamzadeh. All rights reserved.
//
/*
Abstract:
View controller for editing Reminder details
*/


import UIKit
import CoreLocation

enum ReminderAnnotationDetailAction: Int {
	case cancel, save, remove
}

protocol ReminderAnnotationDetailDelegate {
	func reminderAnnotationDetailDidFinish(_ controller: ReminderAnnotationDetail, withAction action: ReminderAnnotationDetailAction)
}

class ReminderAnnotationDetail: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {

	
	@IBOutlet var table: UITableView!
	@IBOutlet var titleCell: UITableViewCell!
	@IBOutlet var titleText: UITextField!
	@IBOutlet var radiusCell: UITableViewCell!
	@IBOutlet var radiusSlider: UISlider!
	
	var delegate: ReminderAnnotationDetailDelegate?
	
	var reminder: ReminderAnnotation! {
		didSet {
			self.updateFields()
		}
	}
	
	var originalRegion: CLCircularRegion!
	
	/*
	// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
	- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
	// Custom initialization
	}
	return self;
	}
	*/
	
	
    override func viewDidLoad() {
        super.viewDidLoad()
		self.updateFields()
	}
	
	
	func updateFields() {
		titleText?.text = reminder.title
		radiusSlider?.minimumValue = Float(RegionManager.shared.minDistance)
		radiusSlider?.maximumValue = 10000.0
//		radiusSlider?.maximumValue = Float(RegionManager.shared.maxDistance)
		let value = Float(reminder.radius)
		radiusSlider?.value = value

		
	}
	
	/*
	// Override to allow orientations other than the default portrait orientation.
	- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
	}
	*/
	
	@IBAction func save(_ sender: Any) {
		// assign fields back into the annotation then call
		
		self.originalRegion = self.reminder.region
		
		reminder.title = titleText.text
		reminder.radius = CLLocationDistance(radiusSlider.value)
		
		self.delegate?.reminderAnnotationDetailDidFinish(self, withAction: .save)
	}
	
	@IBAction func cancel(_ sender: Any) {
		// just return, nothing happened
		self.delegate?.reminderAnnotationDetailDidFinish(self, withAction: .cancel)
	}

	@IBAction func remove() {
		// just return, delegate should delete the annotation
		self.delegate?.reminderAnnotationDetailDidFinish(self, withAction: .remove)
	}

	@IBAction func sliderChanged(_ sender: UISlider) {
		self.table.reloadSections(IndexSet(arrayLiteral: 1), with: .none)
	}

	deinit {
		self.originalRegion = nil
		self.reminder = nil
	}
	
	//MARK: - UITextFieldDelegate
	
	// UITextField delegate response to dismiss the keyboard upon return
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return true
	}
	
	//MARK: - UITableViewDataSource
	func numberOfSections(in tableView: UITableView) -> Int {
		return 4
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		var numRows: Int = 0
		
		switch (section) {
		case 0, 1:
			numRows = 1
		case 2:
			numRows = 2
		case 3:
			numRows = 1
		default:
			assertionFailure("don't know about this section")
		}
		
		return numRows
	}
	
	
	// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
	// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		print(indexPath)
		
		var cell: UITableViewCell!
		
		switch indexPath.section {
		case 0:
			cell = self.titleCell
			
		case 1:
			cell = self.radiusCell

		case 2:
			if (indexPath.row == 0) {
				cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
				cell?.textLabel?.text = "Latitude"
				cell?.detailTextLabel?.text = "\(reminder.coordinate.latitude)"
			} else {
				cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
				cell?.textLabel?.text = "Longitude"
				cell?.detailTextLabel?.text = "\(reminder.coordinate.longitude)"
			}

		case 3:
			cell = UITableViewCell(style: .default, reuseIdentifier: nil)
			cell?.textLabel?.text = "Delete"
			cell.textLabel?.textColor = .red
			cell.textLabel?.textAlignment = .center
			
		default:
			assertionFailure("don't know about this section")
		}
		
		if indexPath.section != 3 {
			cell?.selectionStyle = .none
		}

		
		return cell ?? UITableViewCell()
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if indexPath.section == 3 {
			self.remove()
		}
	}
	
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		var header: String?
		
		switch (section) {
		case 0:
			header = "Remember to"
			
		case 1:
			header = "within"

		case 2:
			header = "of"
			
		default:
			header = nil
		}
		
		return header
		
	}// fixed font style. use custom view (UILabel) if you want something different
	
	func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		var footer: String?
		
		switch (section) {
		case 1:
			footer = "\(radiusSlider?.value ?? 0) meters"
			
		default:
			footer = nil
		}
		
		return footer
	}
	
}
