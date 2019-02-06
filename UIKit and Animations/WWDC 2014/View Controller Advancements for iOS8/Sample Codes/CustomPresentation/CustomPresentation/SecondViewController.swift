//
//  SecondViewController.swift
//  CustomPresentation
//
//  Created by Seyed Samad Gholamzadeh on 7/26/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController {

	var transitionDelegate: UIViewControllerTransitioningDelegate!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//		let visual = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
//		self.view = visual
//		self.view.backgroundColor = UIColor.white.withAlphaComponent(0.6)
		self.view.layer.cornerRadius = 20
		self.view.clipsToBounds = true
		
		let button = UIButton(type: .system)
		button.frame = CGRect(x: 100, y: 100, width: 100, height: 50)
		button.setTitle("Tap Me", for: .normal)
		button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
		self.view.addSubview(button)
//		(self.view as? UIVisualEffectView)?.contentView.addSubview(button)
    }

	
	@objc func buttonTapped(_ sender: UIButton) {
//		self.dismiss(animated: true, completion: nil)
		
//		let tvc = NewTableViewController()
//		self.transitionDelegate = AAPLOverlayTransitioningDelegate()
//		tvc.modalPresentationStyle = .custom
//		tvc.transitioningDelegate = self.transitionDelegate
//		let pc = tvc.presentationController
//
//		self.present(tvc, animated: true, completion: nil)
		let size = CGSize(width: 100, height: 500)
		
		UIView.animate(withDuration: 0.3) {
			self.view.bounds.size.height = size.height
//			self.preferredContentSize.height = size.height
			
		}
		(self.presentationController as! AAPLOverlayPresentationController).size?.height = size.height

	}
	
	
	
}
