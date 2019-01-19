//
//  SSControlsTableViewController.swift
//  Spaceship_Swift
//
//  Created by Seyed Samad Gholamzadeh on 6/20/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

class SSControlsTableViewController: UITableViewController {

	var spaceship: SSSpaceship! {
		didSet {
			if spaceship != oldValue {
				self.updateValues()
			}
		}
	}

	@IBOutlet weak var gravitySwitch: UISwitch!
	@IBOutlet weak var shieldLabel: UILabel!
	@IBOutlet weak var shieldStepper: UIStepper!
	@IBOutlet weak var speedSlider: UISlider!

    override func viewDidLoad() {
        super.viewDidLoad()

		SSThemeManager.customize(self.tableView)
		let theme = SSThemeManager.shared
		self.speedSlider.minimumValueImage = theme.speedSliderMinImage
		self.speedSlider.maximumValueImage = theme.speedSliderMaxImage
		
		if let baseTintColor = theme.baseTintColor {
			self.shieldLabel.textColor = baseTintColor
		}
		else if let mainColor = theme.mainColor {
			self.shieldLabel.textColor = mainColor
		}
		
		self.updateValues()
		
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}

	override func awakeFromNib() {
		super.awakeFromNib()
		
		if let item = self.navigationController?.tabBarItem {
			SSThemeManager.customize(item, for: .controls)
		}
		
		NotificationCenter.default.addObserver(self, selector: #selector(spaceshipDidChange(_:)), name: NSNotification.Name(rawValue: SSSpaceshipDidChangeNotification), object: nil)
	}
	
	@objc func spaceshipDidChange( _ notification: Notification) {
		self.spaceship = notification.object as! SSSpaceship
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		
		if segue.identifier == "showLogs" {
			let navController = segue.destination as! UINavigationController
			let controller = navController.topViewController as! SSLogsViewController
			controller.spaceship = self.spaceship
		}
	}
	
	@IBAction func changeGravity( _ sender: UISwitch) {
		self.spaceship.artificialGravity = sender.isOn
	}
	
	@IBAction func changeShield( _ sender: UIStepper) {
		self.spaceship.shield = Float(sender.value / 100.0)
		self.updateValues()
	}
	
	@IBAction func changeSpeed( _ sender: UISlider) {
		self.spaceship.speed = sender.value
	}
	
    // MARK:  - Controls
	
	func updateValues() {
		self.gravitySwitch?.setOn(self.spaceship.artificialGravity, animated: false)
		let shieldPercent = round(100.0 * self.spaceship.shield)
		self.shieldLabel?.text = "\(shieldPercent)"
		self.shieldStepper?.value = Double(shieldPercent)
		self.speedSlider?.setValue(self.spaceship.speed, animated: false)
	}
	

}
