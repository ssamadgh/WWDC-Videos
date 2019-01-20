//
//  ViewController.swift
//  CostumeTransition
//
//  Created by Seyed Samad Gholamzadeh on 11/7/1394 AP.
//  Copyright © 1394 AP Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
	
	let transitionManager = TransitionManager()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
	}
	
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		
		// this gets a reference to the screen that we're about to transition to
		let toViewController = segue.destination as! ViewController2
		
		// instead of using the default transition animation, we'll ask
		// the segue to use our custom TransitionManager object to manage the transition animation
		toViewController.transitioningDelegate = self.transitionManager
		
	}
	
	@IBAction func Exit(_ segue: UIStoryboardSegue) {
		
	}
	
	
}

