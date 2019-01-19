//
//  ViewController.swift
//  UIKitRendering
//
//  Created by Seyed Samad Gholamzadeh on 8/24/1396 AP.
//  Copyright © 1396 AP Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		self.addImageLabel()
		self.addFastImageLabel()


	}
	
	func addImageLabel() {
		let imageLabel = ImageLabel(frame: CGRect(x: 0, y: 0, width: 300, height: 44), title: "CuriousFrog")
		let imageLabelReflection = ImageLabel(frame: CGRect(x: 0, y: 0, width: 300, height: 44), title: "CuriousFrog", isReflection: true)
		
		imageLabel.center = self.view.center
		
		imageLabel.center.y -= 150
		
		imageLabelReflection.center = imageLabel.center
		imageLabelReflection.frame.origin.y = imageLabel.frame.origin.y + imageLabel.frame.size.height
		self.view.addSubview(imageLabel)
		self.view.addSubview(imageLabelReflection)

	}
	
	func addFastImageLabel() {
		//BananaFrog
		let imageLabel = ImageLabelFast(frame: CGRect(x: 0, y: 0, width: 300, height: 44), title: "CuriousFrog")
		let imageLabelReflection = ImageLabelFast(frame: CGRect(x: 0, y: 0, width: 300, height: 44), title: "CuriousFrog", isReflection: true)
		
		imageLabel.center = self.view.center
		imageLabelReflection.center = self.view.center
		imageLabelReflection.frame.origin.y = imageLabel.frame.origin.y + imageLabel.frame.size.height
		self.view.addSubview(imageLabel)
		self.view.addSubview(imageLabelReflection)
		
	}

	
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
//		addReflection(isReflection: true)
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	
	
}

