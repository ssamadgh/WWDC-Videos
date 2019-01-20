//
//  ViewController.swift
//  PresentationController
//
//  Created by Seyed Samad Gholamzadeh on 10/18/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

class PresentingViewController: UIViewController {

	var transitionDelegate: UIViewControllerTransitioningDelegate!

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		
	}
	
	
	@IBAction func presentButtonAction(_ sender: UIButton) {
		let prenentedVC = PresentedViewController()
		self.present(prenentedVC, animated: true, completion: nil)
	}
	

}

