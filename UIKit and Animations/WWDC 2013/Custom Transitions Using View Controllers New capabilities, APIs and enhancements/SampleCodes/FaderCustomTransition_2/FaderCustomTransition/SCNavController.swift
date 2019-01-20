//
//  ViewController.swift
//  FaderCustomTransition
//
//  Created by Seyed Samad Gholamzadeh on 6/16/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

class SCNavController: UINavigationController {

	var navDelegate: UINavigationControllerDelegate!
		
	override func loadView() {
		super.loadView()

		self.navDelegate = SCNavControllerDelegate()
		self.delegate = navDelegate
	}

}

