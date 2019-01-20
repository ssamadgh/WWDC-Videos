//
//  ViewController.swift
//  CustomTransition
//
//  Created by Seyed Samad Gholamzadeh on 6/16/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

	let transitionDelegate = TransitionDelegate()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	@IBAction func unwindToVC(_ sender: UIStoryboardSegue) {

		// Use data from the view controller which initiated the unwind segue
	}

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		
		// this gets a reference to the screen that we're about to transition to
		let toViewController = segue.destination as UIViewController
		
		// instead of using the default transition animation, we'll ask
		// the segue to use our custom TransitionManager object to manage the transition animation
		toViewController.transitioningDelegate = self.transitionDelegate
		
	}
	
}

