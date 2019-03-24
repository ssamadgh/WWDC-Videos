//
//  FlipsideViewController.swift
//  SongMap_Swift
//
//  Created by Seyed Samad Gholamzadeh on 3/15/19.
//  Copyright © 2019 Seyed Samad Gholamzadeh. All rights reserved.
//
/*
Abstract:
The FlipsideViewController is instantiated by the MainViewController and manages the utility view showing user preferences.
*/

import UIKit

protocol FlipsideViewControllerDelegate {
	func flipsideViewControllerDidFinish(_ controller: FlipsideViewController)
}

let monitorLocationKey = "MonitorLocation"

class FlipsideViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

	
	var delegate: FlipsideViewControllerDelegate?
	@IBOutlet weak var preferencesView: UITableView!
	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		self.view.backgroundColor = UIColor.lightGray
    }
    

	@objc func monitorLocation(_ sender: UISwitch) {
		UserDefaults.standard.set(sender.isOn, forKey: monitorLocationKey)
	}
	
	@IBAction func done(_ sender: Any) {
		self.delegate?.flipsideViewControllerDidFinish(self)
	}
	
	//MARK: - UITableViewDataSource
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 1
	}
	
	// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
	// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
		let onOff = UISwitch()
		onOff.isOn = UserDefaults.standard.bool(forKey: monitorLocationKey)
		onOff.addTarget(self, action: #selector(monitorLocation), for: UIControl.Event.valueChanged)
		cell.textLabel?.text = "Monitor location"
		cell.accessoryView = onOff
		return cell
	}
	
	func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		return "SongMap uses the Significant Change Location Service to log your movement in the background."
	}
	
}
