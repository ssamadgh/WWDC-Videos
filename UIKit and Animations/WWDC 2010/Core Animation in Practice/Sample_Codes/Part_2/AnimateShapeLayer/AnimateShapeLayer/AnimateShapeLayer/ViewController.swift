//
//  ViewController.swift
//  AnimateShapeLayer
//
//  Created by Seyed Samad Gholamzadeh on 3/9/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		
		//		self.makeShapeLayer()
		self.makeShapeLayerAnimately()

	}
	
	func makeShapeLayer() {
		let width: CGFloat = 640
		let height: CGFloat = 640
		
		let shapeLayer = CAShapeLayer()
		shapeLayer.frame = CGRect(x: 0, y: 0,
								  width: width, height: height)
		
		let path = CGMutablePath()
		
		stride(from: 0, to: CGFloat.pi * 2, by: CGFloat.pi / 6).forEach {
			angle in
			var transform  = CGAffineTransform(rotationAngle: angle)
				.concatenating(CGAffineTransform(translationX: width / 2, y: height / 2))
			
			let petal = CGPath(ellipseIn: CGRect(x: -20, y: 0, width: 40, height: 100),
							   transform: &transform)
			
			path.addPath(petal)
		}
		
		shapeLayer.path = path
		shapeLayer.strokeColor = UIColor.red.cgColor
		shapeLayer.fillColor = UIColor.yellow.cgColor
		shapeLayer.fillRule = kCAFillRuleEvenOdd
		
		self.view.layer.addSublayer(shapeLayer)
	}
	
	func makeShapeLayerAnimately() {
		let width: CGFloat = 640
		let height: CGFloat = 640
		
		let shapeLayer = CAShapeLayer()
		shapeLayer.frame = CGRect(x: 0, y: 0,
								  width: width, height: height)
		
		let path = CGMutablePath()
		
		stride(from: 0, to: CGFloat.pi * 2, by: CGFloat.pi / 6).forEach {
			angle in
			var transform  = CGAffineTransform(rotationAngle: angle)
				.concatenating(CGAffineTransform(translationX: width / 2, y: height / 2))
			
			let petal = CGPath(ellipseIn: CGRect(x: -20, y: 0, width: 40, height: 100),
							   transform: &transform)
			
			path.addPath(petal)
		}
		
		let path2 = CGMutablePath()
		
		stride(from: 0, to: CGFloat.pi * 2, by: CGFloat.pi / 6).forEach {
			angle in
			var transform  = CGAffineTransform(rotationAngle: angle)
				.concatenating(CGAffineTransform(translationX: width / 2, y: height / 2))
			
			let petal = CGPath(ellipseIn: CGRect(x: -20, y: 0, width: 50, height: 100),
							   transform: &transform)
			
			path2.addPath(petal)
		}
		
		
		//		shapeLayer.path = path
		shapeLayer.strokeColor = UIColor.red.cgColor
		shapeLayer.fillColor = UIColor.yellow.cgColor
		shapeLayer.fillRule = kCAFillRuleEvenOdd
				shapeLayer.position = self.view.center
		//		shapeLayer.bounds = CGRect(x: -20, y: 0, width: 40, height: 100)
		
		let anim = CABasicAnimation(keyPath: "path")
		anim.fromValue = path
		anim.toValue = path2
		anim.duration = 3
		anim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
		anim.autoreverses = true
		anim.repeatCount = Float.greatestFiniteMagnitude
		shapeLayer.add(anim, forKey: nil)
		
		self.view.layer.addSublayer(shapeLayer)
	}


	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}


}

