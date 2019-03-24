//
//  LocationDetailTableViewController.swift
//  LocateMe_Swift
//
//  Created by Seyed Samad Gholamzadeh on 3/7/19.
//  Copyright © 2019 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit
import CoreLocation

class LocationDetailViewController: UITableViewController {

	enum LocationDetailSection: Int {
		case attributes, accuracy, courseAndSpeed
		
		static var allValues = [attributes, accuracy, courseAndSpeed]
		
		var cellId: String {
			switch self {
			case .attributes:
				return "StatusCellID"
			case .accuracy:
				return "BestMeasurementCellID"
			case .courseAndSpeed:
				return "OtherMeasurementsCellID"
			}
		}
		
	}

	let kLocationAttributeCellID = "LocationAttributeCellID"
	
	var location: CLLocation!
	
	lazy var dateFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateStyle = .medium
		formatter.timeStyle = .long
		return formatter
	}()

	override func viewDidLoad() {
		super.viewDidLoad()
		self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: kLocationAttributeCellID)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.title = NSLocalizedString("LocationInfo", comment: "LocationInfo")
		self.tableView.reloadData()
	}
	
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return (section == LocationDetailSection.attributes.rawValue) ? 3: 2
    }

	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		var headerTitle: String? = nil
		
		switch section {
		case LocationDetailSection.attributes.rawValue:
			headerTitle = NSLocalizedString("Attributes", comment: "Attributes")
			
		case LocationDetailSection.accuracy.rawValue:
			headerTitle = NSLocalizedString("Accuracy", comment: "Accuracy")
			
		default:
			headerTitle = NSLocalizedString("Course and Speed", comment: "Course and Speed")
		}
		
		return headerTitle
	}
	
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: kLocationAttributeCellID, for: indexPath)
		
		let cell = UITableViewCell(style: .value2, reuseIdentifier: kLocationAttributeCellID)
		cell.selectionStyle = .none

        // Configure the cell...
		
		if indexPath.section == LocationDetailSection.attributes.rawValue {
			switch (indexPath.row) {
			case 0:
				cell.textLabel?.text = NSLocalizedString("timestamp", comment: "timestamp")
				cell.detailTextLabel?.text = self.dateFormatter.string(from: location.timestamp)
			
			case 1:
				cell.textLabel?.text = NSLocalizedString("coordinate", comment: "coordinate")
				if (location.horizontalAccuracy < 0) {
				} else {
					cell.detailTextLabel?.text = location.localizedCoordinateString
				}
			
			default:
				cell.textLabel?.text = NSLocalizedString("altitude", comment: "altitude")
				cell.detailTextLabel?.text = location.localizedAltitudeString;
			
			}
		} else if indexPath.section == LocationDetailSection.accuracy.rawValue {
			switch (indexPath.row) {
			case 0:
				cell.textLabel?.text = NSLocalizedString("horizontal", comment: "horizontal")
				cell.detailTextLabel?.text = location.localizedHorizontalAccuracyString;
			
			default:
				cell.textLabel?.text = NSLocalizedString("vertical", comment: "vertical")
				cell.detailTextLabel?.text = location.localizedVerticalAccuracyString;
			}
		} else {
			switch (indexPath.row) {
			case 0:
				cell.textLabel?.text = NSLocalizedString("course", comment: "course")
				cell.detailTextLabel?.text = self.location.localizedCourseString;
			
			default:
				cell.textLabel?.text = NSLocalizedString("speed", comment: "speed")
				cell.detailTextLabel?.text = self.location.localizedSpeedString
			
			}
		}

		
        return cell
    }

}
