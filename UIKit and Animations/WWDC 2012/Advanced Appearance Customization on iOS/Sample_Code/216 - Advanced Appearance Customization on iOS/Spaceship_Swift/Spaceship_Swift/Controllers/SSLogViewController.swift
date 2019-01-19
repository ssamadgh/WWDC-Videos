//
//  SSLogViewController.swift
//  Spaceship_Swift
//
//  Created by Seyed Samad Gholamzadeh on 6/20/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

class SSLogViewController: UIViewController {

	//MARK: - Accessors

	var log: SSLog! {
		didSet {
			if log != oldValue {
				let title = self.log.dateDescription
				self.title = title
				self.updateLog()
			}
		}
	}
	
	@IBOutlet weak var logTextView: UITextView!

	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.logTextView.allowsEditingTextAttributes = true
		self.updateLog()
	}

	//MARK: - LOgs
	
	func updateLog() {
		let attributedText = self.log.attributedText
		self.logTextView.attributedText = attributedText
	}
	
}
