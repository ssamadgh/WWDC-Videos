//
//  ViewController.swift
//  PresentationController
//
//  Created by Seyed Samad Gholamzadeh on 10/18/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

class PresentedViewController: UIViewController {
	
	var transitionDelegate: UIViewControllerTransitioningDelegate!

	init() {
		super.init(nibName: nil, bundle: nil)
		self.modalPresentationStyle = .custom
		self.transitionDelegate = TransitioningDelegate()
		self.transitioningDelegate = self.transitionDelegate
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	deinit {
		print("PresentedViewController deinited")
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		self.view.backgroundColor = .orange
	}
	
	
	
}

