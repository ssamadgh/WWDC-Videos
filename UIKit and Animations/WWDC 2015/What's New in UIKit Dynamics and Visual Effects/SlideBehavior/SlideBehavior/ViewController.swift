//
//  ViewController.swift
//  SlideBehavior
//
//  Created by Seyed Samad Gholamzadeh on 11/12/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

class ViewController : UIViewController {
	
	var visualView: UIVisualEffectView!
	var vibrancyView: UIVisualEffectView!
	
	var animator: UIDynamicAnimator?
	var slideBehavior: SlideBehavior!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		animator = UIDynamicAnimator(referenceView: self.view)
		
		let position1 = CGPoint(x: 0, y: 0)
		let view = self.configureView(at: position1)
		
		slideBehavior = SlideBehavior(item: view)
		animator?.addBehavior(slideBehavior)
		
		animator?.setValue(true, forKey: "debugEnabled")
	}
	
	override func viewWillAppear(_ animated: Bool) {
	}
	
	func configureView(at position: CGPoint) -> UIView {
		print(self.view.frame)
		let frame = self.view.bounds
		let style = UIBlurEffect.Style.extraLight
		let view = UIVisualEffectView(effect: UIBlurEffect(style: style))
		let vibrancy = UIVisualEffectView(effect: UIVibrancyEffect(blurEffect: UIBlurEffect(style: style)))
		vibrancy.frame = frame
		
		let label = UILabel(frame: CGRect(x: 30, y: 30, width: 100, height: 100))
		label.text = "Hello World!"
		label.font = UIFont.boldSystemFont(ofSize: 50)
		label.sizeToFit()
		label.center.x = frame.width/2
		label.center.y = frame.height/2
		
		vibrancy.contentView.addSubview(label)

		view.contentView.addSubview(vibrancy)
		
			view.frame = frame
		
		self.view.addSubview(view)
		

		let pangGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGestureAction(_:)))
		view.addGestureRecognizer(pangGestureRecognizer)
		
		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureAction(_:)))
		view.addGestureRecognizer(tapGesture)

		self.visualView = view
		self.vibrancyView = vibrancy
		
		return view
	}
	
	@objc func panGestureAction(_ sender: UIPanGestureRecognizer) {
		
		
		guard let targetView = sender.view else { return }
		
		switch sender.state {
			
		case .began:
			slideBehavior.isEnabled = false
			
		case .changed:
			let translation = sender.translation(in: targetView.superview)

			targetView.center.y += translation.y
			sender.setTranslation(CGPoint.zero, in: self.view)
			
		case.ended:
			if targetView.center.y < 0 {
				slideBehavior.addLinearVelocity(CGPoint(x: 0, y: -1000))
			}
			else {
				slideBehavior.isEnabled = true
			}
			
			
		default: break
			
		}
	}
	
	@objc func tapGestureAction(_ sender: UITapGestureRecognizer) {
//		if sender.state == .began {

			UIView.animate(withDuration: 2.0) {
				let effect = UIBlurEffect(style: UIBlurEffect.Style.dark)
				self.visualView.effect = effect
				self.vibrancyView.effect = UIVibrancyEffect(blurEffect: effect)
			}
//		}
	}
	
	
}
