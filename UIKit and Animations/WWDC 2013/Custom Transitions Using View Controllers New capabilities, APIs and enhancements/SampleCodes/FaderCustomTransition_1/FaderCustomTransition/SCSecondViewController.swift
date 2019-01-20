//
//  SCSecondViewController.swift
//  FaderCustomTransition
//
//  Created by Seyed Samad Gholamzadeh on 6/16/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

class SCSecondViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		self.title = "Second VC"
		
    }
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { (timer) in
			timer.invalidate()
			self.dismiss(animated: true, completion: nil)

		}
		
	}
	
}
