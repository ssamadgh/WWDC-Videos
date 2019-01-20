//
//  SCFirstViewController.swift
//  FaderCustomTransition
//
//  Created by Seyed Samad Gholamzadeh on 6/16/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

class SCFirstViewController: UIViewController {
	
	let transDelegate = SCTransitionDelegate()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.title = "First VC"
	}
		
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		
		if let toVC = segue.destination as? SCSecondViewController {
			toVC.transitioningDelegate = transDelegate
			toVC.modalPresentationStyle = .custom
		}
	}
}
