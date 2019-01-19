//
//  ViewController.swift
//  MotionAlongAPath_Swift
//
//  Created by Seyed Samad Gholamzadeh on 3/6/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

let pictureX = 160
let pictureY = 210

let trashX = 620
let trashY = 900


class MotionAlongAPathViewController: UIViewController {

	var mainView: MainView!
	var thumbnail: UIView!
	var trash: UIView!
	
	override func loadView() {
		
		if mainView == nil {
			let frame = UIScreen.main.bounds
			mainView = MainView(frame: frame)
			mainView.backgroundColor = UIColor.white
			mainView.isOpaque = true
			
			trash = UIImageView(frame: CGRect(x: 0, y: 0, width: 160, height: 160))
			trash.backgroundColor = UIColor.darkGray
			trash.center = CGPoint(x: trashX, y: trashY)
			mainView.addSubview(trash)
			
			thumbnail = UIImageView(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
			thumbnail.backgroundColor = UIColor.blue
			thumbnail.center = CGPoint(x: pictureX, y: pictureY)
			mainView.addSubview(thumbnail)
			
			let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(thumbnailPressed(_:)))
			thumbnail.addGestureRecognizer(tapGestureRecognizer)
			thumbnail.isUserInteractionEnabled = true
		}
		self.view = mainView
		
	}
	
	
	@objc func thumbnailPressed(_ sender: Any) {
		
		// This is the naive approach...
		/*
		UIView.beginAnimations("MoveAnimation", context: nil)
		UIView.setAnimationDuration(1.0)
		thumbnail.center = CGPoint(x: trashX, y: trashY)
		thumbnail.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
		thumbnail.alpha = 0.5
		UIView.commitAnimations()
		*/
		

		let path = CGMutablePath()
		path.move(to: CGPoint(x: pictureX, y: pictureY))
		path.addQuadCurve(to: CGPoint(x: trashX, y: trashY), control: CGPoint(x: trashX, y: pictureY))
		
		// Uncomment this to draw the path the thumbnail will fallow
//		mainView.path = path
		
		let pathAnimation = CAKeyframeAnimation(keyPath: "position")
		pathAnimation.path = path
		pathAnimation.duration = 1.0

		let scaleAnimation = CABasicAnimation(keyPath: "transform")
		let t = CATransform3DMakeScale(0.1, 0.1, 1.0)
		scaleAnimation.toValue = NSValue(caTransform3D: t)

		let alphaAnimation = CABasicAnimation(keyPath: "opacity")
		alphaAnimation.toValue = NSNumber(value: 0.5)

		let animationGroup = CAAnimationGroup()
		animationGroup.animations = [pathAnimation, scaleAnimation, alphaAnimation]
		animationGroup.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
		animationGroup.duration = 1.0
		thumbnail.layer.add(animationGroup, forKey: nil)
		
	}

}

