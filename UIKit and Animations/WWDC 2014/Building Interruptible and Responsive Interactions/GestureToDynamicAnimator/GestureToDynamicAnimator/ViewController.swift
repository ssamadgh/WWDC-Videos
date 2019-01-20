//
//  ViewController.swift
//  GestureToDynamicAnimator
//
//  Created by Seyed Samad Gholamzadeh on 11/10/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
	
	var dynamicAnimator: UIDynamicAnimator?
	var collisionBehavior: UICollisionBehavior!
	var dynamicItemBehavior: UIDynamicItemBehavior!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		dynamicAnimator = UIDynamicAnimator(referenceView: self.view)
		
		let position1 = CGPoint(x: 50, y: 100)
		let view1 = self.configureView(at: position1)
		
		let position2 = CGPoint(x: 150, y: 100)
		let view2 = self.configureView(at: position2)
		
		let position3 = CGPoint(x: 250, y: 100)
		let view3 = self.configureView(at: position3)
		
		dynamicItemBehavior = UIDynamicItemBehavior(items: [])
		dynamicItemBehavior.resistance = 3.0
		dynamicItemBehavior.angularResistance = 3.0
		
		collisionBehavior = UICollisionBehavior(items: [view1, view2, view3])
		collisionBehavior.translatesReferenceBoundsIntoBoundary = true
		
		dynamicAnimator?.addBehavior(dynamicItemBehavior)
		dynamicAnimator?.addBehavior(collisionBehavior)

	}
	
	func configureView(at position: CGPoint) -> UIView {
		let view = UIView(frame: CGRect(x: position.x, y: position.y, width: 100, height: 100))
		view.backgroundColor = UIColor(red: 39/255, green: 129/255, blue: 168/255, alpha: 1)
		
		self.view.addSubview(view)
		
		let pangGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGestureAction(_:)))
		view.addGestureRecognizer(pangGestureRecognizer)
		
		return view
	}
	
	@objc func panGestureAction(_ sender: UIPanGestureRecognizer) {
		
		
		guard let targetView = sender.view else { return }
		
		switch sender.state {
			
		case .began:
			dynamicItemBehavior.removeItem(targetView)
			collisionBehavior.removeItem(targetView)
			
		case .changed:
			let translation = sender.translation(in: targetView.superview)
			
			targetView.center.x += translation.x
			targetView.center.y += translation.y
			sender.setTranslation(CGPoint.zero, in: self.view)
			
		case.ended:
			let velocity = sender.velocity(in: targetView.superview)
			collisionBehavior.addItem(targetView)
			dynamicItemBehavior.addItem(targetView)
			dynamicItemBehavior.addLinearVelocity(velocity, for: targetView)
			
		default: break
			
		}
	}

	
}

