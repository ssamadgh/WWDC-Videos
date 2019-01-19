//
//  ViewController.swift
//  Skeleton_Swift
//
//  Created by Seyed Samad Gholamzadeh on 3/8/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

class SkeletonViewController: UIViewController {
	
	var mrGeometry: Avatar!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		
		//Create an Avatar object
		mrGeometry = Avatar()
		
		//Posotion the generated skeleton layer tree and add it to the view's root layer
		mrGeometry.layer.position = CGPoint(x: 150, y: self.view.bounds.midY)
		self.view.layer.addSublayer(mrGeometry.layer)
		
		//Add a gesture recognizer to notify us when a Tap is performed
		let recognizer = UITapGestureRecognizer(target: self, action: #selector(handleGesture(_:)))
		self.view.addGestureRecognizer(recognizer)
	}
	
	//Called when a Tap is performed
	@objc func handleGesture(_ recognizer: UIGestureRecognizer) {
		
		//Tell the Avatar to animate the skeleton layer tree
		mrGeometry.wave()
	}
	
}

