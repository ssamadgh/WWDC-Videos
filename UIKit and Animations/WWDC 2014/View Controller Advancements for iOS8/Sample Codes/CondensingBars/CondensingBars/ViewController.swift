//
//  ViewController.swift
//  CondensingBars
//
//  Created by Seyed Samad Gholamzadeh on 10/18/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		self.navigationController?.hidesBarsOnTap = true
		self.navigationController?.hidesBarsOnSwipe = true
		self.navigationController?.hidesBarsWhenVerticallyCompact = true
	}


}

