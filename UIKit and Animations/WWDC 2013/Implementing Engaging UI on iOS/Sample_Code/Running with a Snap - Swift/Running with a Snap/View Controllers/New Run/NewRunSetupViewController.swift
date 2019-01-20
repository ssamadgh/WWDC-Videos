//
//  NewRunSetupViewController.swift
//  Running with a Snap
//
//  Created by Seyed Samad Gholamzadeh on 7/11/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

class NewRunSetupViewController: UIViewController {

	@IBOutlet weak var  locationTextField: UITextField!
	@IBOutlet weak var  backgroundView: UIImageView!
	@IBOutlet weak var  cancelButton: UIButton!
	@IBOutlet weak var  startSessionButton: UIButton!


	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		self.backgroundView.image = (appDelegate as! AppDelegate).interfaceManager.blurredBackgroundImage

//		let bgImage = (appDelegate as! AppDelegate).interfaceManager.backgroundImage
//		self.backgroundView.image = bgImage
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		self.locationTextField.becomeFirstResponder()
	}
	
	@IBAction func startRun(_ sender: Any) {
		let run = Run()
		run.whereIs = self.locationTextField.text
		run.whenIs = Date()
		RunManager.save(run)
		
		let vc = CameraCaptureViewController(nibName: nil, bundle: nil)
		vc.run = run
		
		self.navigationController?.show(vc, sender: self)
	}
	
	@IBAction func cancel(_ sender: Any) {
		self.navigationController?.popToRootViewController(animated: true)
	}
}
