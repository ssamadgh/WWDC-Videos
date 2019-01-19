//
//  ViewController.swift
//  CATEST
//
//  Created by Seyed Samad Gholamzadeh on 10/7/1396 AP.
//  Copyright © 1396 AP Seyed Samad Gholamzadeh. All rights reserved.
//

import Cocoa
import CoreImage

class ViewController: NSViewController {

	var imageView: NSImageView!
	var imageView2: NSImageView!
	var imageView3: NSImageView!
	
	var layer: CALayer!
	
	var transitioningLayer: CATextLayer!

	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
//		self.view.wantsLayer
		
		view.layerUsesCoreImageFilters = true
		
		view.layer = CALayer()
//		transitioningLayer = CATextLayer()
//		transitioningLayer.frame = CGRect(x: 100, y: 100,
//										  width: 320, height: 160)
//
//		view.layer!.addSublayer(transitioningLayer)
//
//		// Initial "red" state
//		transitioningLayer.backgroundColor = NSColor.red.cgColor
//		transitioningLayer.string = "Red"
		
		let firstImage = #imageLiteral(resourceName: "02")
		let layerContents = firstImage.layerContents(forContentsScale: 1)

		self.layer = CALayer()
		layer.frame = CGRect(x: 0, y: 0, width: 500, height: 200)
		layer.contents = layerContents
		self.view.layer?.addSublayer(layer)
		
	}
	
	override func viewDidAppear() {
//		imageView = NSImageView(frame: NSRect(x: 0, y: 0, width: 300, height: 200))
//		imageView.image = #imageLiteral(resourceName: "IMG_6093")
//		self.view.addSubview(imageView)
//
		
		
//		imageView2 = NSImageView()
//		imageView2.image = #imageLiteral(resourceName: "02")
//		imageView2.layer = CALayer()
//		imageView2.layer?.contents = #imageLiteral(resourceName: "02")
//
//		self.view.layer?.addSublayer(imageView2.layer!)
//////
////		imageView3 = NSImageView(frame: NSRect(x: 0, y: 0, width: 300, height: 200))
////		imageView3.image = #imageLiteral(resourceName: "IMG_7353")
////		self.view.addSubview(imageView3)

		

	}
	
	func transitionAnimation2(for view: NSView, from oldView: NSImageView, to newView: NSImageView) {
		
		
		let aFilter = CIFilter(name: "CIBarsSwipeTransition")!
		aFilter.setValue(NSNumber(value: 3.14), forKey: "inputAngle")
		aFilter.setValue(NSNumber(value: 30.0), forKey: "inputWidth")
		aFilter.setValue(NSNumber(value: 10.0), forKey: "inputBarOffset")
		
		// Create the transition object
		let transition = CATransition()
		transition.startProgress = 0
		transition.endProgress = 1.0
		transition.filter = aFilter
		transition.duration = 1.0
//		let dict = [NSAnimatablePropertyKey("subviews"): transition]
//		view.animations = dict
//		view.animator().replaceSubview(oldView, with: newView)
		
		newView.isHidden = true
		oldView.layer?.add(transition, forKey: "transition")
		newView.layer?.add(transition, forKey: "transition")
		oldView.isHidden = true
		newView.isHidden = false

	}
	
	func transitionAnimation(for view: NSView, from oldView: NSImageView, to newView: NSImageView) {
//		let parameters = ["inputOpacity":NSNumber(value: 1.0), "inputTime":NSNumber(value: 1.0), "inputImage": oldView.image!, "inputTargetImage": newView.image!, "inputWidth": NSNumber(value: 100.0)] as [String : Any]
////
//		let filter = CIFilter(name: "CICopyMachineTransition")
//		filter!.setDefaults()
////		filter?.setValuesForKeys(keyValues)
////		print(filter?.attributes)
//		let anim = CATransition()
////		anim.type = kCATransitionMoveIn
////		anim.subtype = kCATransitionFromLeft
//		anim.filter = filter
//
////		anim.type = "cube"
////		anim.subtype = kCATransitionFromLeft
//
//		anim.duration = 1
//		anim.repeatCount = Float.greatestFiniteMagnitude
//		let dict = [NSAnimatablePropertyKey("subviews"): anim]
//		view.layerUsesCoreImageFilters = true
//		view.animations = dict
//		view.animator().replaceSubview(oldView, with: newView)
		
		
		
		
		
		
	}
	
	
	
	func popAnimation() {
		let imageView = NSImageView(frame: NSRect(x: 200, y: 140, width: 100, height: 50))
		imageView.image = #imageLiteral(resourceName: "IMG_6093")
		self.view.addSubview(imageView)
		
		let alphaAnimation = CABasicAnimation(keyPath: "alphaValue")
		alphaAnimation.fromValue = 0
		alphaAnimation.toValue = 1
		
		let sizeAnimation = CAKeyframeAnimation(keyPath: "frame")
		
		let startRect = NSRect(x: 300, y: 300, width: 0, height: 0)
		let popRect = NSRect(x: 222, y: 222, width: 128, height: 128)
		let endRect = NSRect(x: 250, y: 250, width: 100, height: 100)
		
		let values = [startRect, popRect, endRect]
		let times = [NSNumber(value: 0.0), NSNumber(value: 0.8), NSNumber(value: 1.0)]
		sizeAnimation.values = values
		sizeAnimation.keyTimes = times
		
		let group = CAAnimationGroup()
		group.animations = [sizeAnimation, alphaAnimation]
		let dict = [NSAnimatablePropertyKey("alphaValue"): group]
		imageView.animations = dict
		imageView.animator().alphaValue = 1.0

	}
	
	
	func curveAnimation() {
		let imageView = NSImageView(frame: NSRect(x: 200, y: 140, width: 100, height: 50))
		imageView.image = #imageLiteral(resourceName: "IMG_6093")
		self.view.addSubview(imageView)
		
		let anim = CAKeyframeAnimation()
		var path = CGMutablePath()
		path.move(to: CGPoint(x: 200, y: 240))
		path.addCurve(to: CGPoint(x: 190, y: 40), control1: CGPoint(x: 100, y: 140), control2: CGPoint(x: 100, y: 140))
		anim.path = path
		anim.repeatCount = Float.greatestFiniteMagnitude
		anim.duration = 1
		let dict = [NSAnimatablePropertyKey("frameOrigin"): anim]
		imageView.animations = dict
		let newOrigin = CGPoint(x: 100, y: 540)
		imageView.animator().setFrameOrigin(newOrigin)
	}
	
	@IBAction func animate(_ sender: NSButton) {
//		self.transitionAnimation(for: self.imageView, from: imageView2, to: imageView3)

		
		let transition = CATransition()
		transition.duration = 2

		transition.filter = CIFilter(name: "CICopyMachineTransition")
		layer.add(transition, forKey: "transition")
//
		let secondImage = #imageLiteral(resourceName: "IMG_6093")
		let layerContents = secondImage.layerContents(forContentsScale: 1)
		layer.contents = layerContents

	}
	
	func runTransition() {
//		let parameters = ["inputOpacity":NSNumber(value: 1.0), "inputTime":NSNumber(value: 1.0), "inputImage": oldView.image!, "inputTargetImage": newView.image!, "inputWidth": NSNumber(value: 100.0)] as [String : Any]

		
		let transition = CATransition()
		transition.duration = 2
		let filter = CIFilter(name: "CICopyMachineTransition")
//		filter?.setValue(NSNumber(value: 10.0), forKey: "inputWidth")
		transition.filter = filter
		
		transitioningLayer.add(transition,
							   forKey: "transition")
		
		// Transition to "blue" state
		transitioningLayer.backgroundColor = NSColor.blue.cgColor
		transitioningLayer.string = "Blue"

	}
	

	override var representedObject: Any? {
		didSet {
		// Update the view, if already loaded.
		}
	}


}

