//
//  ViewController.swift
//  PopoverPresentationController
//
//  Created by Seyed Samad Gholamzadeh on 7/19/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIPopoverPresentationControllerDelegate {

	@IBOutlet weak var leftItem: UIBarButtonItem!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	@IBAction func leftItemAction(_ sender: UIBarButtonItem) {
		let tableVC = TableViewController()
		tableVC.modalPresentationStyle = .popover
		let popPC = tableVC.popoverPresentationController
		popPC?.barButtonItem = self.leftItem
		popPC?.delegate = self
		self.present(tableVC, animated: true, completion: nil)
	}
}

