//
//  ViewController.swift
//  KeyboardPractice
//
//  Created by Seyed Samad Gholamzadeh on 5/19/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
	
	var textField: UITextField!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		
		let someView = UIView()
		someView.frame.size.height = 50
		someView.backgroundColor = UIColor.green
		
		self.textField = UITextField(frame: CGRect(x: -50, y: -50, width: 50, height: 50))
		self.view.addSubview(textField)
		textField.inputAccessoryView = someView
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	@IBAction func actionButton(_ sender: Any) {
		if textField.isEditing {
			textField.resignFirstResponder()
		}
		else {
			textField.becomeFirstResponder()
		}

	}
	
}

