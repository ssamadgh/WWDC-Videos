//
//  ViewController.swift
//  Toggle Bird
//
//  Created by Seyed Samad Gholamzadeh on 10/17/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

	var _birdExpanded: Bool = false

	
	var birdExpanded: Bool = false {
		didSet {
			if self._birdExpanded != self.birdExpanded {
				self._birdExpanded = self.birdExpanded
				
				UIView.animate(withDuration: 0, animations: {
					
					if self.birdExpanded {
						self.heightConstraint.constant = 300
					}
					else {
						self.heightConstraint.constant = 0
					}
					self.view.layoutIfNeeded()
					
				}) { (finished) in
					
					
				}

			}
		}
	}
	
	@IBOutlet weak var toggleBird: UIButton!
	@IBOutlet weak var heightConstraint: NSLayoutConstraint!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
	}

	@IBAction func toggleBirdAction(_ sender: UIButton) {
		
		UIView.animate(withDuration: 1.0, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0, options: UIView.AnimationOptions(), animations: {
			self.birdExpanded = !self.birdExpanded
		}, completion: nil)
		
	}
	
}

