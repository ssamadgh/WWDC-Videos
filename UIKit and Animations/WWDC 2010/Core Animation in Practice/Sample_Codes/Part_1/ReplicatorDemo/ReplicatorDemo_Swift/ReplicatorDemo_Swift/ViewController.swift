//
//  ViewController.swift
//  ReplicatorDemo_Swift
//
//  Created by Seyed Samad Gholamzadeh on 3/9/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		self.view.backgroundColor = .black
		let controller = AppController()
		controller.view = self.view
		controller.awakeFromNib()
		
//		let layer = CALayer()
//		layer.contents = UIImage(named: "samad")?.cgImage
//		layer.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
//		self.view.layer.addSublayer(layer)
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}


}

