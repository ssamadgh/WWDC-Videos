//
//  AAPLCoolPresentationController.swift
//  LookInside_Swift
//
//  Created by Seyed Samad Gholamzadeh on 7/18/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

class AAPLCoolPresentationController: UIPresentationController {
	
	var bigFlowerImageView: UIImageView!
	var carlImageView: UIImageView!
	
	var jaguarPrintImageH: UIImage!
	var jaguarPrintImageV: UIImage!

	var topJaguarPrintImageView: UIImageView!
	var bottomJaguarPrintImageView: UIImageView!
	
	var leftJaguarPrintImageView: UIImageView!
	var rightJaguarPrintImageView: UIImageView!

	var dimmingView: UIView!
	
	override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
		super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
		
		self.dimmingView = UIView()
		self.dimmingView.backgroundColor = UIColor.purple.withAlphaComponent(0.4)
		self.bigFlowerImageView = UIImageView(image: UIImage(named: "BigFlower"))
		self.carlImageView = UIImageView(image: UIImage(named: "Carl"))
		self.carlImageView.frame = CGRect(x: 0, y: 0, width: 500, height: 245)
		
		self.jaguarPrintImageH = UIImage(named: "JaguarH")?.resizableImage(withCapInsets: .zero, resizingMode: .tile)
		self.jaguarPrintImageV = UIImage(named: "JaguarV")?.resizableImage(withCapInsets: .zero, resizingMode: .tile)
		
		self.topJaguarPrintImageView = UIImageView(image: jaguarPrintImageH)
		self.bottomJaguarPrintImageView = UIImageView(image: jaguarPrintImageH)
		
		self.leftJaguarPrintImageView = UIImageView(image: jaguarPrintImageV)
		self.rightJaguarPrintImageView = UIImageView(image: jaguarPrintImageV)
	}
	
	override var frameOfPresentedViewInContainerView: CGRect {
		let containerBounds = self.containerView!.bounds
		var presentedViewFrame = CGRect.zero
		presentedViewFrame.size = CGSize(width: 300, height: 500)
		presentedViewFrame.origin = CGPoint(x: containerBounds.size.width / 2.0, y: containerBounds.size.height / 2.0)
		presentedViewFrame.origin.x -= presentedViewFrame.size.width / 2.0
		presentedViewFrame.origin.y -= presentedViewFrame.size.height / 2.0
		return presentedViewFrame
	}
	
	override func presentationTransitionWillBegin() {
		super.presentationTransitionWillBegin()
		
		self.addViewsToDimmingView()
		
		self.dimmingView.alpha = 0.0
		
		self.presentedViewController.transitionCoordinator?.animate(alongsideTransition: { (context) in
			self.dimmingView.alpha = 1.0
		}, completion: nil)

		self.moveJaguarPrintToPresentedPosition(false)
		
		UIView.animate(withDuration: 1.0) {
			self.moveJaguarPrintToPresentedPosition(true)
		}
	}
	
	override func containerViewWillLayoutSubviews() {
		self.dimmingView.frame = self.containerView!.bounds
	}
	
	override func containerViewDidLayoutSubviews() {
		var bigFlowerCenter = self.dimmingView.frame.origin
		bigFlowerCenter.x += self.bigFlowerImageView.image!.size.width/4.0
		bigFlowerCenter.y += self.bigFlowerImageView.image!.size.height/4.0
		
		self.bigFlowerImageView.center = bigFlowerCenter
		
		var carlFrame = self.carlImageView.frame
		carlFrame.origin.y = self.dimmingView.bounds.size.height - carlFrame.size.height
		
		self.carlImageView.frame = carlFrame
	}
	
	override func dismissalTransitionWillBegin() {
		super.dismissalTransitionWillBegin()
		
		self.presentedViewController.transitionCoordinator?.animate(alongsideTransition: { (context) in
			self.dimmingView.alpha = 0.0
		}, completion: nil)
	}
	
	func addViewsToDimmingView() {
		self.dimmingView.addSubview(bigFlowerImageView)
		self.dimmingView.addSubview(carlImageView)

		self.dimmingView.addSubview(topJaguarPrintImageView)
		self.dimmingView.addSubview(bottomJaguarPrintImageView)

		self.dimmingView.addSubview(leftJaguarPrintImageView)
		self.dimmingView.addSubview(rightJaguarPrintImageView)

		self.containerView?.addSubview(self.dimmingView)
	}
	
	func moveJaguarPrintToPresentedPosition(_ presentedPosition: Bool) {
		let horizontalJaguarSize = self.jaguarPrintImageH.size
		let verticalJaguarSize = self.jaguarPrintImageV.size
		let frameOfView = self.frameOfPresentedViewInContainerView
		let containerFrame =  self.containerView?.frame
		
		var topFrame = CGRect.zero
		var bottomFrame = CGRect.zero
		var leftFrame = CGRect.zero
		var rightFrame = CGRect.zero

		topFrame.size.height = horizontalJaguarSize.height
		topFrame.size.width = frameOfView.size.width
		bottomFrame.size.height = topFrame.size.height
		bottomFrame.size.width = topFrame.size.width

		leftFrame.size.width = verticalJaguarSize.width
		leftFrame.size.height = frameOfView.size.height
		rightFrame.size.width = leftFrame.size.width
		rightFrame.size.height = leftFrame.size.height

		topFrame.origin.x = frameOfView.origin.x
		bottomFrame.origin.x = frameOfView.origin.x
		
		leftFrame.origin.y = frameOfView.origin.y
		rightFrame.origin.y = frameOfView.origin.y
		
		let frameToAlignAround = presentedPosition ? frameOfView : containerFrame
		
		topFrame.origin.y = frameToAlignAround!.minY - horizontalJaguarSize.height;
		bottomFrame.origin.y = frameToAlignAround!.maxY
		leftFrame.origin.x = frameToAlignAround!.minX - verticalJaguarSize.width;
		rightFrame.origin.x = frameToAlignAround!.maxX
		
		self.topJaguarPrintImageView.frame = topFrame
		self.bottomJaguarPrintImageView.frame = bottomFrame
		self.leftJaguarPrintImageView.frame = leftFrame
		self.rightJaguarPrintImageView.frame = rightFrame
	}
}
