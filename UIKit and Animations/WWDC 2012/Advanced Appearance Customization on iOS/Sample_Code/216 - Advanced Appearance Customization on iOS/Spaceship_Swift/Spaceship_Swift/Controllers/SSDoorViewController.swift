//
//  ViewController.swift
//  Spaceship_Swift
//
//  Created by Seyed Samad Gholamzadeh on 4/27/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

class SSDoorViewController: UIViewController {

	@IBOutlet weak var doorSegmentedControl: UISegmentedControl!
	@IBOutlet weak var doorButton: UIButton!
	@IBOutlet weak var lockButton: UIButton!

	var selectedDoor: Int = 0

	var spaceship: SSSpaceship!

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		SSThemeManager.customize(self.view)
		SSThemeManager.customizeDoorButton(button: self.doorButton)
		self.updateStatus()
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}

	override func awakeFromNib() {
		super.awakeFromNib()
		
		if let item = self.navigationController?.tabBarItem {
			SSThemeManager.customize(item, for: .door)
		}
		
		NotificationCenter.default.addObserver(self, selector: #selector(spaceshipDidChange(_:)), name: NSNotification.Name(rawValue: SSSpaceshipDidChangeNotification), object: nil)

	}
	
	@objc func spaceshipDidChange( _ notification: Notification) {
		self.spaceship = notification.object as! SSSpaceship
	}
	
	//MARK: - Door
	
	var currentDoor: SSDoor {
		
		let isFrontDoor = self.selectedDoor == 0
		return isFrontDoor ? self.spaceship.frontDoor : self.spaceship.backDoor
	}


	func updateStatus() {
		
		let currentDoor = self.currentDoor
		let locked = currentDoor.isLocked
		let open = currentDoor.isOpen
		self.lockButton.isSelected = locked
		self.doorButton.isEnabled = !locked
		self.doorButton.isSelected = open
	}
	
	//MARK: - Actions
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		
		if segue.identifier == "showLogs" {
			let navController = segue.destination as! UINavigationController
			let controller = navController.topViewController as! SSLogsViewController
			controller.spaceship = self.spaceship
		}
	}
	
	@IBAction func changeSelectedDoor(_ sender: UISegmentedControl) {
		self.selectedDoor = sender.selectedSegmentIndex
		self.updateStatus()
	}
	
	@IBAction func toggleCurrentDoor(_ sender: UISegmentedControl) {
		
		var currentDoor = self.currentDoor
		let open = !currentDoor.isOpen
		currentDoor.isOpen = open
		self.updateStatus()
	}

	@IBAction func toggleCurrentLock(_ sender: UISegmentedControl) {
		
		var currentDoor = self.currentDoor
		let locked = !currentDoor.isLocked
		currentDoor.isLocked = locked
		self.updateStatus()
	}


}

