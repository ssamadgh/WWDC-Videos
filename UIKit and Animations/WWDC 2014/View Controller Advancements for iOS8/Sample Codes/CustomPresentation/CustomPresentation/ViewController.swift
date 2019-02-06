//
//  ViewController.swift
//  CustomPresentation
//
//  Created by Seyed Samad Gholamzadeh on 7/25/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIAdaptivePresentationControllerDelegate {

	var transitionDelegate: UIViewControllerTransitioningDelegate!

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
	}

	@IBAction func customPresentAction(_ sender: UIButton) {
		
		let tvc = SecondViewController(nibName: nil, bundle: nil)
		let transitionD = AAPLOverlayTransitioningDelegate()
		transitionD.size = CGSize(width: UIScreen.main.bounds.width*0.9, height: 300)
		self.transitionDelegate = transitionD
		tvc.modalPresentationStyle = .custom
		tvc.transitioningDelegate = self.transitionDelegate
		let pc = tvc.presentationController
		pc!.delegate = self

		self.present(tvc, animated: true, completion: nil)
	}
	
//	func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
//		return .none
//	}
	


}

