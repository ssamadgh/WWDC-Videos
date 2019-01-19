//
//  SSPowerViewController.swift
//  Spaceship_Swift
//
//  Created by Seyed Samad Gholamzadeh on 6/20/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

class SSPowerViewController: UIViewController {

	var spaceship: SSSpaceship!
	var activating: Bool = false
	var activationStatus: Float = 0.0
	
	@IBOutlet weak var powerImageView: UIImageView!
	@IBOutlet weak var progressView: UIProgressView!
	@IBOutlet weak var toggleButton: UIButton!

	override func viewDidLoad() {
        super.viewDidLoad()

		SSThemeManager.customize(self.view)
		
		let theme = SSThemeManager.shared
		
		let normalImage = theme.buttonBackgroundForState(.normal)
		
		if normalImage != nil {
			self.toggleButton.setBackgroundImage(normalImage, for: .normal)
		}
		
		let highlightedImage = theme.buttonBackgroundForState(.highlighted)
		
		if highlightedImage != nil {
			self.toggleButton.setBackgroundImage(highlightedImage, for: .highlighted)
		}
		
		let disabedImage = theme.buttonBackgroundForState(.disabled)
		
		if disabedImage != nil {
			self.toggleButton.setBackgroundImage(disabedImage, for: .disabled)
		}
		
		let highlightedColor = theme.highlightColor
		
		if highlightedColor != nil {
			self.toggleButton.setTitleColor(highlightedColor, for: .normal)
		}
		
		self.updateStatus()
    }
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}

	override func awakeFromNib() {
		super.awakeFromNib()
		
		if let item = self.navigationController?.tabBarItem {
			SSThemeManager.customize(item, for: .power)
		}
		
		NotificationCenter.default.addObserver(self, selector: #selector(spaceshipDidChange(_:)), name: NSNotification.Name(rawValue: SSSpaceshipDidChangeNotification), object: nil)
	}
	
	@objc func spaceshipDidChange( _ notification: Notification) {
		self.spaceship = notification.object as! SSSpaceship
	}
	
	//MARK: - Actions
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		
		if segue.identifier == "showLogs" {
			let navController = segue.destination as! UINavigationController
			let controller = navController.topViewController as! SSLogsViewController
			controller.spaceship = self.spaceship
		}
	}
	
	@IBAction func togglePower(_ sender: UIButton) {
		
		if self.spaceship.isPowerActive {
			self.spaceship.isPowerActive = false
		}
		else {
			self.activating = true
			self.activationStatus = 0.0
			self.increasePower()
		}
		self.updateStatus()
	}
	
	//MARK: - Power
	
	@objc func increasePower() {
		
		self.activationStatus += 0.01
		if self.activationStatus < 1.0 {
			self.perform(#selector(increasePower), with: nil, afterDelay: 0.01)
		}
		else {
			self.activating = false
			self.spaceship.isPowerActive = true
		}
		self.updateStatus()
	}
	
	func updateStatus() {
		
		let active = self.spaceship?.isPowerActive ?? false
		var image: UIImage
		if active {
			image = UIImage.animatedImageNamed("powerOn", duration: 0.3)!
		}
		else {
			image = UIImage(named: "powerOff")!
		}
		self.powerImageView.image = image
		
		self.toggleButton.isEnabled = !self.activating
		let title = active ? NSLocalizedString("Deactivate", comment: "Deactivate") : NSLocalizedString("Activate", comment: "activate")
		self.toggleButton.setTitle(title, for: .normal)
		self.progressView.isHidden = !self.activating
		self.progressView.progress = self.activationStatus
	}
	
	
}
