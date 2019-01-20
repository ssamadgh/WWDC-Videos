//
//  ViewController.swift
//  SplitViewController
//
//  Created by Seyed Samad Gholamzadeh on 10/17/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

	var button: UIButton!
	var toolBar: UIToolbar!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		self.button = UIButton(type: .system)
		self.button.setTitle("Control SplitViewController", for: .normal)
		self.button.addTarget(self, action: #selector(buttonAction(_:)), for: .touchUpInside)
		self.view.addSubview(button)
		self.button.translatesAutoresizingMaskIntoConstraints = false
		self.button.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
		self.button.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
		self.view.backgroundColor = .yellow
		
		self.toolBar = UIToolbar()
		self.view.addSubview(toolBar)
		
		let views = ["tabBar" : toolBar]
		toolBar.translatesAutoresizingMaskIntoConstraints = false
//		let constraints = NSLayoutConstraint.constraints(withVisualFormat: "|-[tabBar]-|", options: .alignAllBottom, metrics: nil, views: views)
		toolBar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
		toolBar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
		toolBar.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
//		tabBar.addConstraints(constraints)
	}

	@objc func buttonAction(_ sender: UIButton) {
		if let parent = self.parent as? UISplitViewController {
			parent.preferredDisplayMode = .primaryOverlay
			self.toolBar.items = [parent.displayModeButtonItem]
			
		}
	}

}

