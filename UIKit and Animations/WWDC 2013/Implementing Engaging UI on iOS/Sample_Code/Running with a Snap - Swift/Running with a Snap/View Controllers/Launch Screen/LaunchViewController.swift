//
//  ViewController.swift
//  Running with a Snap
//
//  Created by Seyed Samad Gholamzadeh on 7/9/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit


class LaunchViewController: UIViewController {


	var updateButtonArt: Bool = false
	
	@IBOutlet weak var backgroundView: UIImageView!
	@IBOutlet weak var makeNewRunButton: UIButton!
	@IBOutlet weak var pastRunButton: UIButton!

	var lensFlareView: LensFlareView!
	
	
	func applyBackground(to button: UIButton, sourceBlurFromView backgroundView: UIView) {
		
		let buttonRectInBGViewCoords = button.convert(button.bounds, to: backgroundView)
		
		UIGraphicsBeginImageContextWithOptions(button.frame.size, false, self.view.window!.screen.scale)
		/*
		Note that in seed 1, drawViewHierarchyInRect: does not function correctly. This has been fixed in seed 2. Seed 1 users will have empty images returned to them.
		*/
		backgroundView.drawHierarchy(in: CGRect(x: -buttonRectInBGViewCoords.origin.x, y: -buttonRectInBGViewCoords.origin.y, width: backgroundView.frame.width, height: backgroundView.frame.height), afterScreenUpdates: false)
		var newBGImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		
		newBGImage = newBGImage?.applyLightEffect()
		button.setBackgroundImage(newBGImage, for: .normal)
		
		button.layer.mask?.frame = button.bounds
		button.layer.cornerRadius = 4.0
		button.layer.masksToBounds = true

		let xAxis = UIInterpolatingMotionEffect(keyPath: "center.x", type: UIInterpolatingMotionEffectType.tiltAlongHorizontalAxis)
		xAxis.minimumRelativeValue = NSNumber(value: -10.0)
		xAxis.maximumRelativeValue = NSNumber(value: 10.0)
		
		let yAxis = UIInterpolatingMotionEffect(keyPath: "center.y", type: UIInterpolatingMotionEffectType.tiltAlongVerticalAxis)
		yAxis.minimumRelativeValue = NSNumber(value: -10.0)
		yAxis.maximumRelativeValue = NSNumber(value: 10.0)

		let group = UIMotionEffectGroup()
		group.motionEffects = [xAxis, yAxis]
		button.addMotionEffect(group)
	}
	
	func updateInterface() {
		if self.updateButtonArt {
			self.applyBackground(to: self.makeNewRunButton, sourceBlurFromView: self.backgroundView)
			self.applyBackground(to: self.pastRunButton, sourceBlurFromView: self.backgroundView)
			self.updateButtonArt = false

		}
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		let bgImage = (appDelegate as! AppDelegate).interfaceManager.backgroundImage
		
		if self.backgroundView.image != bgImage {
			self.backgroundView.image = bgImage
			self.updateButtonArt = true
		}
		
		if self.backgroundView.image != nil {
			if self.lensFlareView != nil {
				// Always generate a unique lens flare each time the launch page is shown
				self.lensFlareView.removeFromSuperview()
			}
			
			self.lensFlareView = LensFlareView(frame: self.view.bounds, flareLineEndPoint: CGPoint(x: 200, y: self.view.bounds.height))
			self.view.insertSubview(self.lensFlareView, aboveSubview: self.backgroundView)
		}
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		self.updateInterface()
	}
	
	@IBAction func startNewRun(_ sender: Any) {
		let vc = NewRunSetupViewController(nibName: nil, bundle: nil)
		self.navigationController?.show(vc, sender: nil)
	}
	
	@IBAction func choosePreviousRun(_ sender: Any) {
		self.navigationController?.setNavigationBarHidden(false, animated: false)
		let vc = PreviousRunPickerViewController(nibName: nil, bundle: nil)
		self.navigationController?.show(vc, sender: nil)
	}

}

