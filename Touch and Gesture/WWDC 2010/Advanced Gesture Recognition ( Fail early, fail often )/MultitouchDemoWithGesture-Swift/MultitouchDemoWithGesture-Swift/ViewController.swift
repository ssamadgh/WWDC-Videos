//
//  ViewController.swift
//  MultitouchDemoWithGesture-Swift
//
//  Created by Seyed Samad Gholamzadeh on 10/30/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIGestureRecognizerDelegate {

	@IBOutlet weak var firstPieceView: UIView!
	@IBOutlet weak var secondPieceView: UIView!
	@IBOutlet weak var thirdPieceView: UIView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		
		self.view.isUserInteractionEnabled = true
		self.view.backgroundColor = .gray
		self.addGestureRecognizers(to: self.view)
		
		self.addGestureRecognizers(to: firstPieceView)
		self.addGestureRecognizers(to: secondPieceView)
		self.addGestureRecognizers(to: thirdPieceView)

	}

	func addGestureRecognizers(to view: UIView) {
		let transformGesture = TtransformGestureRecognizre(target: self, action: #selector(handleTransform(_:)))
		transformGesture.delegate = self
		view.addGestureRecognizer(transformGesture)
		
	}
	
	@objc func handleTransform(_ transformRecognizer:TtransformGestureRecognizre) {
		var transform = transformRecognizer.transform
		
		if transformRecognizer.state == .began {
			transform = transformRecognizer.view?.transform ?? .identity
			transformRecognizer.transform = transform
		}
		
		transformRecognizer.view?.transform = transform
	}

}

