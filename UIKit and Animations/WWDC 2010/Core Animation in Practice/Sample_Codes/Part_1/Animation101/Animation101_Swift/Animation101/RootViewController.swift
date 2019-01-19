//
//  ViewController.swift
//  Animation101
//
//  Created by Seyed Samad Gholamzadeh on 3/7/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		
		let view = RootView(frame: UIScreen.main.bounds)
		self.view = view
	}
	


	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}


}

