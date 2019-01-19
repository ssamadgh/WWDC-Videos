//
//  PlantCareView.swift
//  iPlant_Swift
//
//  Created by Seyed Samad Gholamzadeh on 3/6/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

let numberOfBlades: CGFloat = 9.0

func radians(_ degrees: CGFloat) -> CGFloat {
	return degrees*CGFloat.pi/180
}

class PlantCareView: UIView {
	
	// Display Items
	var waterView: UIImageView!
	var selectedVegetableIcon: UIImageView!
	var volumeLabel: UILabel!
	
	// Buttons
	var carrotButton: UIButton!
	var radishButton: UIButton!
	var onionButton: UIButton!
	var sproutButton: UIButton!
	
	var vegetableSpinner: UIView!
	
	
	
	override init(frame: CGRect) {
		super.init(frame: frame)

		self.clipsToBounds = true

		vegetableSpinner = UIView(frame: CGRect(x: 28, y: 167, width: 259, height: 259))
		vegetableSpinner.backgroundColor = UIColor.clear

		let waterBackground = UIImageView(image: UIImage(named: "lcd"))
		self.addSubview(waterBackground)

		waterView = UIImageView(image: UIImage(named: "water"))
		waterView.frame = rectForWaterWith(level: 100)
		self.addSubview(waterView)
		
		volumeLabel = self.newWaterlabel()
		self.addSubview(volumeLabel)

		let foreground = UIImageView(image: UIImage(named: "flat"))
		self.addSubview(foreground)

		self.setupVegetableButtons()
		
		self.addSubview(vegetableSpinner)
		
		let cover = UIImageView(image: UIImage(named: "WheelCover"))
		self.addSubview(cover)
		
		let infoButton = UIButton(type: .infoDark)
		infoButton.frame = CGRect(x: 280, y: 420, width: 40, height: 40)
		infoButton.addTarget((UIApplication.shared.delegate as! PlantAppDelegate), action: #selector(PlantAppDelegate.showBack(_:)), for: .touchUpInside)
		self.addSubview(infoButton)
		
		self.selectedVegetableIcon = UIImageView(frame: CGRect(x: vegetableSpinner.frame.minX + (vegetableSpinner.frame.width/2) - 37, y: vegetableSpinner.frame.minY, width: 74, height: 74))
		selectedVegetableIcon.image = UIImage(named: "carrot")
		self.addSubview(selectedVegetableIcon)

		let waterPlantButton = UIButton(type: .custom)
		waterPlantButton.setImage(UIImage(named: "drips"), for: .normal)
		waterPlantButton.frame = CGRect(x: frame.width/2.0 - 85.0/2.0 - 2, y: frame.height/2.0 - 85.0/2.0 + 70, width: 85, height: 85)
		waterPlantButton.addTarget(self, action: #selector(startWateringProcedure(_:)), for: .touchUpInside)
		self.addSubview(waterPlantButton)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	/*
	Called when a vegetable button is pressed.
	*/
	@objc func setSelectedVeg(_ sender: Any) {
		
		self.selectedVegetableIcon.alpha = 0.0
		UIView.animate(withDuration: 0.4, animations: {
			let angle = self.spinnerAngleForVegetable(sender)
			self.vegetableSpinner.transform = CGAffineTransform(rotationAngle: angle)
		}) { (finished) in
			self.selectedVegetableIcon.alpha = 1.0
		}
	}
	
	
	/*
	Tell the robot to water the selected plant.
	*/
	@objc func startWateringProcedure(_ sender: Any) {
		
		let robot: RoboGardener = RoboGardener()
		robot.waterPlant()
		
		UIView.animate(withDuration: 0.4, animations: {
			self.volumeLabel.alpha = 0.0
		}) { (finished) in
			UIView.animate(withDuration: 0.6, animations: {
				let newWaterLevel = robot.waterLevel
				
				self.volumeLabel.text = "\(newWaterLevel)"
				self.volumeLabel.alpha = 1.0
				self.waterView.frame = self.rectForWaterWith(level: newWaterLevel)
			})
		}
	}
	
	/*
	Create and setup all the buttons
	*/
	func setupVegetableButtons() {
		
		self.carrotButton = UIButton(frame: CGRect(x: vegetableSpinner.frame.width/2.0 - 37, y: 0, width: 74, height: 74))
		self.assembleVegetableButton(carrotButton)

		self.radishButton = UIButton(frame: CGRect(x: 0, y: vegetableSpinner.frame.height/2.0 - 37, width: 74, height: 74))
		self.assembleVegetableButton(radishButton)

		self.onionButton = UIButton(frame: CGRect(x: vegetableSpinner.frame.width/2.0 - 37, y: vegetableSpinner.frame.height - 74, width: 74, height: 74))
		self.assembleVegetableButton(onionButton)
		
		self.sproutButton = UIButton(frame: CGRect(x: vegetableSpinner.frame.width - 74, y: vegetableSpinner.frame.height/2.0 - 37, width: 74, height: 74))
		self.assembleVegetableButton(sproutButton)
	}
	
	
	/*
	Factory to create a given button
	*/
	func assembleVegetableButton(_ button: UIButton) {
		
		button.transform = CGAffineTransform(rotationAngle: -self.spinnerAngleForVegetable(button))
		button.setImage(self.imageForVarg(button), for: .normal)
		button.addTarget(self, action: #selector(setSelectedVeg(_:)), for: .touchUpInside)
		button.showsTouchWhenHighlighted = true
		self.vegetableSpinner.addSubview(button)
	}

	/*
	Returns the unselected icon of a given vegetable
	*/
	func selectedImageForVarg(_ sender: Any) -> UIImage? {
		
		guard sender is UIButton else {
			return nil
		}
	
		if (sender as! UIButton) == carrotButton {
			return UIImage(named: "carrot")!
		}
		else if (sender as! UIButton) == radishButton {
			return UIImage(named: "radish")!
		}
		else if (sender as! UIButton) == onionButton {
			return UIImage(named: "onion")!
		}
		else if (sender as! UIButton) == sproutButton {
			return UIImage(named: "sprout")!
		}
		
		return nil
	}
	
	
	/*
	Returns the selected icon of a given vegetable
	*/
	func imageForVarg(_ button: UIButton) -> UIImage? {
		
		if (button == carrotButton) {
			return UIImage(named: "ucarrot")!
		} else if (button == radishButton) {
			return UIImage(named: "uradish")!
		} else if (button == onionButton) {
			return UIImage(named: "uonion")!
		} else if (button == sproutButton) {
			return UIImage(named: "usprout")!
		}
		
		return nil
	}
	

	/*
	Returns the angle for a given selected vegetable
	*/
	func spinnerAngleForVegetable(_ sender: Any) -> CGFloat {
		
		self.selectedVegetableIcon?.image = self.selectedImageForVarg(sender)

		var angle: CGFloat = 0.0
		if (sender as! UIButton) == carrotButton {
			angle = 0.0
		}
		else if (sender as! UIButton) == radishButton {
			angle = 90.0
		}
		else if (sender as! UIButton) == onionButton {
			angle = 180.0
		}
		else if (sender as! UIButton) == sproutButton {
			angle = -90.0
		}
		
		return radians(angle)
	}
	
	/*
	Create and setup the water label
	*/
	func newWaterlabel() -> UILabel {
		
		let label = UILabel(frame: CGRect(x: 20, y: 30, width: 280, height: 135))
		label.text = "100%"
		label.font = UIFont(name: "Helvetica", size: 50)
		label.textAlignment = .center
		label.textColor = UIColor.white
		label.backgroundColor = UIColor.clear
		return label
	}

	/*
	Returns a rect for the waters frame at a given level
	*/
	func rectForWaterWith(level: CGFloat) -> CGRect {
		return CGRect(x: 17, y: 10 + (140 * ((100 - level)/100.0)), width: 285, height: 140 * (level/100.0))

	}


}
