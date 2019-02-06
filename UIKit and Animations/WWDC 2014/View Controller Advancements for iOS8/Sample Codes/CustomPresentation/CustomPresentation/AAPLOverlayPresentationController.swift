//
//  AAPLOverlayPresentationController.swift
//  LookInside_Swift
//
//  Created by Seyed Samad Gholamzadeh on 7/18/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

class AAPLOverlayPresentationController: UIPresentationController {
	
	var dimmingView: UIView!
	var size: CGSize?
	
	override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
		super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
		self.prepareDimmingView()
	}
	
	override func presentationTransitionWillBegin() {
		let containerView = self.containerView
		let presentedViewController = self.presentedViewController
		self.dimmingView.frame = containerView!.bounds
		self.dimmingView.alpha = 0.0
		
		containerView?.insertSubview(self.dimmingView, at: 0)
		
		if presentedViewController.transitionCoordinator != nil {
			presentedViewController.transitionCoordinator?.animate(alongsideTransition: { (context) in
				self.dimmingView.alpha = 1.0
			}, completion: nil)
		}
		else {
			self.dimmingView.alpha = 1.0
		}
	}
	
	override func dismissalTransitionWillBegin() {
		let presentedViewController = self.presentedViewController

		if presentedViewController.transitionCoordinator != nil {
			presentedViewController.transitionCoordinator?.animate(alongsideTransition: { (context) in
				self.dimmingView.alpha = 0.0
			}, completion: nil)
		}
		else {
			self.dimmingView.alpha = 0.0
		}
	}
	
	override var adaptivePresentationStyle: UIModalPresentationStyle {
		return .overFullScreen
	}
	
	override func size(forChildContentContainer container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
		let width = floor(parentSize.width * 0.9)
		let height = floor(parentSize.height * 0.7)

		return self.size ?? CGSize(width: width, height: height)
	}
	
	override func containerViewWillLayoutSubviews() {
		self.dimmingView.frame = self.containerView!.bounds
		self.presentedView?.frame = self.frameOfPresentedViewInContainerView
	}
	
	override var shouldPresentInFullscreen: Bool {
		return true
	}
	
	override var frameOfPresentedViewInContainerView: CGRect {
		var presentedViewFrame = CGRect.zero
		let containerBounds = self.containerView!.bounds
		presentedViewFrame.size = self.size(forChildContentContainer: self.presentedViewController, withParentContainerSize: containerBounds.size)
		presentedViewFrame.origin.x = (containerBounds.size.width - presentedViewFrame.size.width)/2
		presentedViewFrame.origin.y = (containerBounds.size.height - presentedViewFrame.size.height)/2

		return presentedViewFrame
	}
	
	func prepareDimmingView() {
		self.dimmingView = UIView()
		self.dimmingView.backgroundColor = UIColor(white: 0.0, alpha: 0.4)
		self.dimmingView.alpha = 0.0
		
		let tap = UITapGestureRecognizer(target: self, action: #selector(dimmingViewTapped(_:)))
		self.dimmingView.addGestureRecognizer(tap)
	}
	
	@objc func dimmingViewTapped(_ gesture: UIGestureRecognizer) {
		if gesture.state == .recognized {
			self.presentedViewController.dismiss(animated: true, completion: nil)
		}
	}
}
