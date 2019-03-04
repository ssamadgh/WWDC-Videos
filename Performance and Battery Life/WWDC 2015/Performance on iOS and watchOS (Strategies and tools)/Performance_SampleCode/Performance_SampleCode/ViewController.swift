//
//  ViewController.swift
//  Performance_SampleCode
//
//  Created by Seyed Samad Gholamzadeh on 2/24/19.
//  Copyright © 2019 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
	}

	@IBAction func doSomeAction(_ sender: UIButton) {
		#if MEASER_PERFORMANCE
		print("This is test version")
		#endif
	}
	

}

