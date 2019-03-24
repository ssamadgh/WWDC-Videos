//
//  TrackLocationViewController.swift
//  LocateMe_Swift
//
//  Created by Seyed Samad Gholamzadeh on 3/7/19.
//  Copyright © 2019 Seyed Samad Gholamzadeh. All rights reserved.
//
/*
Abstract:

Attempts to track the user location with a specific level of accuracy. A "distance filter" indicates the smallest change in location that triggers an update from the location manager to its delegate. Presents a SetupViewController instance so the user can configure the desired accuracy and distance filter. Uses a LocationDetailViewController instance to drill down into details for a given location measurement.

*/

import UIKit
import CoreLocation

class TrackLocationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SetupViewControllerDelegate, CLLocationManagerDelegate {
	
	var setupViewController: SetupViewController!
	@IBOutlet weak var startButton: UIButton!
	@IBOutlet weak var descriptionLabel: UILabel!
	var locationManager: CLLocationManager!
	var locationMeasurements: [CLLocation]!
	@IBOutlet weak var tableView: UITableView!
	var stateString: String!
	
	lazy var dateFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateStyle = .medium
		formatter.timeStyle = .long
		return formatter
	}()

	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Do any additional setup after loading the view.
		self.locationMeasurements = []
		
		self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: kStatusCellID)
		self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: kOtherMeasurementsCellID)

	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		guard let nv = segue.destination as? UINavigationController else { return }
		self.setupViewController = nv.viewControllers.first as? SetupViewController
		self.setupViewController.delegate = self
	}
	
	@IBAction func start(_ send: UIButton) {
		guard self.setupViewController != nil else { return }
		self.present(self.setupViewController, animated: true, completion: nil)
	}
	
	
	// The reset method allows the user to repeatedly test the location functionality.
	// In addition to discarding all of the location measurements from the previous "run",
	// it animates a transition in the user interface between the table which displays location
	// data and the start button and description label presented at launch.
	//

	@objc func reset() {
		self.disableMyLocationBasedFeatures()
		self.locationMeasurements.removeAll()
		
		// fade in the rest of the UI and fade out the table view
		UIView.animate(withDuration: 0.6, animations: {
			self.startButton.alpha = 1.0
			self.descriptionLabel.alpha = 1.0
			self.tableView.alpha = 0.0
			self.navigationItem.setLeftBarButton(nil, animated: true)
		})
	}
	
	//MARK: - Location Manager Interactions
	
	// This method is invoked when the user hits "Done" in the setup view controller.
	// The options chosen by the user are passed in as a dictionary. The keys for this dictionary
	// are declared in SetupViewController.h.
	//
	func setupViewController(_ controller: SetupViewController, didFinishSetupWithInfo setupInfo: [String : Any]) {
		self.startButton.alpha = 0.0
		self.descriptionLabel.alpha = 0.0
		self.tableView.alpha = 1.0
		
		// Create the manager object
		self.locationManager = CLLocationManager()
		self.locationManager.delegate = self
		
		// This is the most important property to set for the manager. It ultimately determines how the manager will
		// attempt to acquire location and thus, the amount of power that will be consumed.
		self.locationManager.desiredAccuracy = setupInfo[kSetupInfoKeyAccuracy] as! CLLocationAccuracy
		
		// When "tracking" the user, the distance filter can be used to control the frequency with which location measurements
		// are delivered by the manager. If the change in distance is less than the filter, a location will not be delivered.
		self.locationManager.distanceFilter = setupInfo[kSetupInfoKeyDistanceFilter] as! CLLocationDistance
		
		// Once configured, the location manager must be "started".
		//
		// for iOS 8, specific user level permission is required,
		// "when-in-use" authorization grants access to the user's location
		//
		// important: be sure to include NSLocationWhenInUseUsageDescription along with its
		// explanation string in your Info.plist or startUpdatingLocation will not work.
		//
		
		self.enableBasicLocationServices()
		
		self.stateString = NSLocalizedString("Tracking", comment: "Tracking")
		self.tableView.reloadData()
		
		let resetItem = UIBarButtonItem(title: NSLocalizedString("Reset", comment: "Reset"), style: .plain, target: self, action: #selector(reset))
		self.navigationItem.setLeftBarButton(resetItem, animated: true)
	}
	
	func enableBasicLocationServices() {
		locationManager.delegate = self
		
		switch CLLocationManager.authorizationStatus() {
		case .notDetermined:
			// Request when-in-use authorization initially
			locationManager.requestWhenInUseAuthorization()
			break
			
		case .restricted, .denied:
			// Disable location features
			disableMyLocationBasedFeatures()
			break
			
		case .authorizedWhenInUse, .authorizedAlways:
			// Enable location features
			enableMyWhenInUseFeatures()
			break
		}
	}
	
	func enableMyWhenInUseFeatures() {
		self.locationManager.startUpdatingLocation()
		//		self.locationManager.requestLocation()
	}
	
	func disableMyLocationBasedFeatures() {
		self.locationManager.stopUpdatingLocation()
	}

	
	func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
		switch status {
		case .restricted, .denied:
			disableMyLocationBasedFeatures()
			break
			
		case .authorizedWhenInUse:
			enableMyWhenInUseFeatures()
			break
			
		case .notDetermined, .authorizedAlways:
			break
		}
	}
	
	
	// We want to get and store a location measurement that meets the desired accuracy.
	// For this example, we are going to use horizontal accuracy as the deciding factor.
	// In other cases, you may wish to use vertical accuracy, or both together.
	//
	
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		// test that the horizontal accuracy does not indicate an invalid measurement
		guard let newLocation = locations.last else { return }
		if newLocation.horizontalAccuracy < 0 {
			return
		}
		
		// test the age of the location measurement to determine if the measurement is cached
		// in most cases you will not want to rely on cached measurements
		//
		let locationAge = -(newLocation.timestamp.timeIntervalSinceNow)
		if locationAge > 5.0 {
			return
		}
		
		// store all of the measurements, just so we can see what kind of data we might receive
		self.locationMeasurements.append(newLocation)
		
		// update the display with the new location data
		self.tableView.reloadData()
	}
	
	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		// The location "unknown" error simply means the manager is currently unable to get the location.
		if (error as! CLError).code != CLError.locationUnknown {
			self.stopUpdatingLocationWithMessage(NSLocalizedString("Error", comment:"Error"))
		}
	}
	
	@objc func stopUpdatingLocationWithMessage(_ state: String) {
		self.stateString = state
		self.tableView.reloadData()
		
		self.locationManager.stopUpdatingLocation()
		self.locationManager.delegate = nil
	}

	//MARK: - UITableViewDataSource
	
	// The table view has two sections. The first has 1 row which displays status information.
	// The second has a row for each valid location object received from the location manager.
	//
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return (self.locationMeasurements.count > 0) ? 2 : 1
	}
	
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		var headerTitle: String?
		
		switch (section) {
		case 0:
			headerTitle = NSLocalizedString("Status", comment: "Status")
		default:
			headerTitle = NSLocalizedString("All Measurements", comment: "All Measurements")
		}
		
		return headerTitle
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		var numRows: Int = 0
		
		switch (section) {
		case GetLocationSection.status.rawValue:
			numRows = 1
			
		default:
			numRows = self.locationMeasurements.count
		}
		
		return numRows
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		var cell: UITableViewCell!
		
		switch (indexPath.section) {
		case GetLocationSection.status.rawValue:
			// The cell for the status row uses the cell style "UITableViewCellStyleValue1", which has a label on the left side of the cell with left-aligned and black text; on the right side is a label that has smaller blue text and is right-aligned. An activity indicator has been added to the cell and is animated while the location manager is updating. The cell's text label displays the current state of the manager.
			let kStatusCellActivityIndicatorTag = 2
			var activityIndicator: UIActivityIndicatorView!
			cell = tableView.dequeueReusableCell(withIdentifier: kStatusCellID, for: indexPath)
			cell?.selectionStyle = .none
			cell.textLabel?.text = self.stateString
			
			if let view = cell.contentView.viewWithTag(kStatusCellActivityIndicatorTag) as? UIActivityIndicatorView {
				activityIndicator = view
			}
			else {
				let activityIndicatorView = UIActivityIndicatorView(style: .gray)
				var frame = activityIndicatorView.frame
				let cellWidth = cell.contentView.frame.size.width
				frame.origin = CGPoint(x: cellWidth - frame.width - 16, y: 12)
				activityIndicatorView.frame = frame
				activityIndicatorView.autoresizingMask = UIView.AutoresizingMask.flexibleLeftMargin
				activityIndicatorView.tag = kStatusCellActivityIndicatorTag
				cell.contentView.addSubview(activityIndicatorView)
				
				activityIndicator = activityIndicatorView
			}
			
			cell.contentView.bringSubviewToFront(activityIndicator)
			
			
			if self.stateString == NSLocalizedString("Tracking", comment: "Tracking") {
				if !activityIndicator.isAnimating {
					activityIndicator.startAnimating()
				}
			}
			else {
				if activityIndicator.isAnimating {
					activityIndicator.stopAnimating()
				}
			}
			
		default:
			// The cells for the location rows use the cell style "UITableViewCellStyleSubtitle", which has a left-aligned label across the top and a left-aligned label below it in smaller gray text. The text label shows the coordinates for the location and the detail text label shows its timestamp.
			cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: kOtherMeasurementsCellID)
			cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
			
			let location = self.locationMeasurements[indexPath.row]
			cell.textLabel?.text = location.localizedCoordinateString
			cell.detailTextLabel?.text = self.dateFormatter.string(from: location.timestamp)
		}
		
		return cell
	}
	
	//MARK: - UITableViewDelegate
	
	// Delegate method invoked before the user selects a row.
	// In this sample, we use it to prevent selection in the first section of the table view.
	//
	func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
		return (indexPath.section == 0) ? nil : indexPath
	}
	
	// Delegate method invoked after the user selects a row. Selecting a row containing a location object
	// will navigate to a new view controller displaying details about that location.
	//
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		self.tableView.deselectRow(at: indexPath, animated: true)
		let location = self.locationMeasurements[indexPath.row]
		let detailVC = LocationDetailViewController(style: .grouped)
		detailVC.location = location
		self.show(detailVC, sender: self)
	}
	
}
