//
//  ViewController.swift
//  DynamicsCatalog_Swift
//
//  Created by Seyed Samad Gholamzadeh on 6/27/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.

// Abstract: Provides the "Gravity" demonstration.


import UIKit

class APLGravityViewController: UIViewController {

	@IBOutlet weak var square1: UIImageView!
	
	 var animator: UIDynamicAnimator!
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		let animator = UIDynamicAnimator(referenceView: self.view)
		let gravityBehavior = UIGravityBehavior(items: [self.square1])
		animator.addBehavior(gravityBehavior)
		
		self.animator = animator

	}

}

