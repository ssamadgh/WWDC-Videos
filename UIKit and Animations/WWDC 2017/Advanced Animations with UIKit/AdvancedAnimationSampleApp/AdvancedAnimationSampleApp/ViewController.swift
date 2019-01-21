//
//  ViewController.swift
//  AdvancedAnimationSampleApp
//
//  Created by Seyed Samad Gholamzadeh on 11/14/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
	let duration: Double = 1
	
	enum State {
		case expanded, collapsed
	}
	
	// Tracks all running animators
	var runningAnimators = [UIViewPropertyAnimator]()
	
	var animator: UIViewPropertyAnimator!
	
	var childVC: ChildViewController!
	
	var containerView: CustomView!
	
	var isExpanded: Bool = false
	
	var collapsedY: CGFloat!
	
	var expandedY: CGFloat!

	var state: State = .collapsed
	
	var fraction: CGFloat {
		return self.runningAnimators.first?.fractionComplete ?? 0
	}
	
	var isReversed: Bool {
		return self.runningAnimators.first?.isReversed ?? false
	}
	
	@IBOutlet weak var navigationBar: UINavigationBar!
	
	@IBOutlet weak var blurEffectView: UIVisualEffectView!
	
	
	@IBOutlet weak var arrowButton: UIButton!

	@IBOutlet weak var titleLabel: UILabel!

	@IBOutlet weak var detailsButton: UIButton!

	@IBOutlet weak var barButtonArrow: UIButton!
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		self.navigationBar.titleTextAttributes = [
			NSAttributedString.Key.font : UIFont(name: "Helvetica", size: 18)!,
			NSAttributedString.Key.foregroundColor : UIColor.darkGray
		]
		
//		for family in UIFont.familyNames {
//			print(UIFont.fontNames(forFamilyName: family))
//		}
		
		self.blurEffectView.effect = nil
		self.arrowButton.alpha = 0
		self.titleLabel.alpha = 0
		self.detailsButton.alpha = 0
		
		self.setupChildViewController()
	}
	
	func setupChildViewController() {
		
		self.collapsedY = UIScreen.main.bounds.height - 60
		self.expandedY = 80
		self.containerView = CustomView(frame:  CGRect(x: 0, y: self.collapsedY, width: self.view.bounds.width, height: self.view.bounds.height))
		self.childVC = (UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Child") as! ChildViewController)
		self.addChild(self.childVC)
		self.containerView.addSubview(self.childVC.view)
		self.childVC.didMove(toParent: self)
		self.childVC.bigHeaderLable.alpha = 0

		self.view.addSubview(self.containerView)
		
		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
		
		let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
		
		self.childVC.headerView.gestureRecognizers = [tapGesture]
		self.childVC.headerView.isUserInteractionEnabled = true
		self.containerView.addGestureRecognizer(panGesture)
		
	}
	
	// Perform all animations with animators if not already running
	func animateTransitionIfNeeded(state: State, duration: TimeInterval) {
		if runningAnimators.isEmpty {

			self.configureFrameAnimation(state: state, duration: duration)
			self.configureBlurAnimation(state: state, duration: duration)
			self.configureLabelAnimation(state: state, duration: duration)
			self.configureCornerAnimation(state: state, duration: duration)
			self.configureTopButtonsAnimation(state: state, duration: duration)
		}
	}
	
	func configureFrameAnimation(state: State, duration: TimeInterval) {
		
		let frameAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
			switch state {
			case .expanded:
				self.containerView.frame.origin.y = self.collapsedY
			case .collapsed:
				self.containerView.frame.origin.y = self.expandedY
			}
		}
		
		frameAnimator.isManualHitTestingEnabled = true
		
		frameAnimator.addCompletion { (position) in
			self.runningAnimators.removeAll()
			if position == UIViewAnimatingPosition.end {
				self.state = state == .collapsed ? .expanded : .collapsed
			}
		}
		
		frameAnimator.startAnimation()
		runningAnimators.append(frameAnimator)
	}
	
	func configureBlurAnimation(state: State, duration: TimeInterval) {
		
		let timing: UITimingCurveProvider
		switch state {
		case .collapsed:
			timing = UICubicTimingParameters(controlPoint1: CGPoint(x: 0.75, y: 0.1), controlPoint2: CGPoint(x: 0.9, y: 0.25))
		case .expanded:
			timing = UICubicTimingParameters(controlPoint1: CGPoint(x: 0.1, y: 0.75),controlPoint2: CGPoint(x: 0.25, y: 0.9))
		}
		let blurAnimator = UIViewPropertyAnimator(duration: duration, timingParameters: timing)
		
		blurAnimator.addAnimations {
			switch state {
			case .collapsed:
				self.blurEffectView.effect = UIBlurEffect(style: UIBlurEffect.Style.dark)
				
			case .expanded:
				self.blurEffectView.effect = nil
			}
		}
		blurAnimator.scrubsLinearly = false
		
		blurAnimator.startAnimation()
		runningAnimators.append(blurAnimator)

	}
	
	func configureLabelAnimation(state: State, duration: TimeInterval) {
		let inLabel: UILabel = state == .collapsed ? self.childVC.bigHeaderLable : self.childVC.smallHeaderLable
		let outLabel: UILabel = state == .collapsed ? self.childVC.smallHeaderLable : self.childVC.bigHeaderLable
		let inWScale = inLabel.bounds.width/outLabel.bounds.width
		let inHScale = inLabel.bounds.height/outLabel.bounds.height
		let inLabelScale = CGAffineTransform(scaleX: inWScale, y: inHScale)
		let inY = inLabel.frame.minY
		let outY = outLabel.frame.minY
		let inH = inLabel.bounds.height
		let outH = outLabel.bounds.height
		let dH = (inH - outH)*0.5
		let dy = inY - outY
		let translationY = dy + dH
		let inLabelTranslation = CGAffineTransform(translationX: 0, y: translationY)
		
		let transformAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
			inLabel.transform = CGAffineTransform.identity
			outLabel.transform = inLabelScale.concatenating(inLabelTranslation)
		}
		transformAnimator.scrubsLinearly = false
		
		transformAnimator.addCompletion { (position) in
			if position == .start {
				inLabel.transform = .identity
			}
			
			if position == .end {
				outLabel.transform = .identity
			}
		}
		
		transformAnimator.startAnimation()
		runningAnimators.append(transformAnimator)

		
		let inLabelAnimator = UIViewPropertyAnimator(duration: duration, curve: .easeIn) {
			inLabel.alpha = 1
		}
		inLabelAnimator.scrubsLinearly = false
		
		inLabelAnimator.startAnimation()
		runningAnimators.append(inLabelAnimator)

		let outLabelAnimator = UIViewPropertyAnimator(duration: duration, curve: .easeOut) {
			outLabel.alpha = 0
		}
		outLabelAnimator.scrubsLinearly = false

		outLabelAnimator.startAnimation()
		runningAnimators.append(outLabelAnimator)

	}
	
	func configureCornerAnimation(state: State, duration: TimeInterval) {
		self.containerView.clipsToBounds = true
		self.containerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
		let cornerAnimator = UIViewPropertyAnimator(duration: duration, curve: .linear) {
			switch state {
			case .collapsed:
				self.containerView.layer.cornerRadius = 12
			case .expanded:
				self.containerView.layer.cornerRadius = 0
			}
		}
		
		cornerAnimator.startAnimation()
		runningAnimators.append(cornerAnimator)
	}
	
	func configureTopButtonsAnimation(state: State, duration: TimeInterval) {
		
		let buttonAnimator = UIViewPropertyAnimator(duration: duration, curve: .linear) {
			
			UIView.animateKeyframes(withDuration: 0.0, delay: 0.0, options: [], animations: {
			switch state {
			case .collapsed:
				UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.5) {
					// Start with delay and finish with rest of animations detailsButton.alpha = 1
					self.detailsButton.alpha = 1
					self.titleLabel.alpha = 1
					self.arrowButton.alpha = 1
				}
				UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 1.0) {
					self.arrowButton.transform = CGAffineTransform(rotationAngle: -.pi/2)
					self.barButtonArrow.transform = CGAffineTransform(rotationAngle: -.pi/2)
				}
				
			case .expanded:
				UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.5) {
					// Start immediately and finish in half the time detailsButton.alpha = 0
					self.detailsButton.alpha = 0
					self.titleLabel.alpha = 0
					self.arrowButton.alpha = 0
					self.arrowButton.transform = .identity
					self.barButtonArrow.transform = .identity

				}
				
			}
		}, completion: nil)
			
		}
		
		buttonAnimator.startAnimation()
		runningAnimators.append(buttonAnimator)

		
	}
	
	
	// Starts transition if necessary or reverses it on tap
	func animateOrReverseRunningTransition(state: State, duration: TimeInterval) {
		if runningAnimators.isEmpty {
			animateTransitionIfNeeded(state: state, duration: duration)
		} else {
			for animator in runningAnimators {
				animator.isReversed = !animator.isReversed
			}
		}
	}
	
	// Starts transition if necessary and pauses on pan .begin
	func startInteractiveTransition(state: State, duration: TimeInterval) {
		if runningAnimators.isEmpty {
			animateTransitionIfNeeded(state: state, duration: duration)
		}
		
		for animator in runningAnimators {
			animator.pauseAnimation()
		}
	}
	
	// Scrubs transition on pan .changed
	func updateInteractiveTransition(fractionComplete: CGFloat) {
		for animator in runningAnimators {
			animator.fractionComplete = fractionComplete
		}
		
	}
	
	// Continues or reverse transition on pan .ended
	func continueInteractiveTransition(cancel: Bool) {
		for animator in runningAnimators {
			animator.isReversed = cancel
			animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
		}
	}
	
	
	@objc func handleTap(_ sender: UITapGestureRecognizer) {
		self.animateOrReverseRunningTransition(state: self.state, duration: duration)
	}
	
	@objc func handlePan(_ sender: UIPanGestureRecognizer) {
		
		switch sender.state {
		case .began:
			self.startInteractiveTransition(state: self.state, duration: duration)
			//			let value = self.state == .collapsed ? -fraction : fraction
			//			sender.setTranslation(CGPoint(x: 0, y: value), in: containerView)
			
		case .changed:
			
			let translation = sender.translation(in: containerView)
			let dy = translation.y
			var sign: CGFloat = 1
			switch (self.state, self.isReversed) {
			case (.collapsed, false): sign = -1
			case (.collapsed, true): sign = 1
			case (.expanded, false): sign = 1
			case (.expanded, true): sign = -1
			}
			
			//			let value = self.state == .collapsed ? -translation.y : translation.y
			let value = sign*dy
			let distance = self.collapsedY
			let fraction = self.fraction + value/distance!
			self.updateInteractiveTransition(fractionComplete: fraction)
			sender.setTranslation(CGPoint.zero, in: containerView)
			
			
		case .ended:
			let cancel = isReversed ? fraction >= 0.6 : fraction <= 0.4
			self.continueInteractiveTransition(cancel: cancel)
			
		default:
			break
		}
	}
	
	
	@IBAction func arrowButtonAction(_ sender: UIButton) {
		
		self.animateTransitionIfNeeded(state: self.state, duration: self.duration)
	}
	
}

