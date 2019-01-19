//
//  Avatar.swift
//  Skeleton_Swift
//
//  Created by Seyed Samad Gholamzadeh on 3/8/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

class Avatar: NSObject {

	//the top of the skeleton layer tree
	var avatar: CALayer!
	
	//The elements of the skeleton
	var head: CAShapeLayer!
	var humerus: CALayer!
	var radiusUlna: CALayer!
	var hand: CALayer!

	//the top of the skeleton layer tree (sythesized to avatar)
	var layer: CALayer {
		return avatar
	}
	
	override init() {
		super.init()
		
		//Create the base layer
		avatar = CALayer()
		avatar.bounds = CGRect(x: 0, y: 0, width: 200, height: 400)
		
		//Create the head
		head = CAShapeLayer()
		let headImage = UIImage(named: "head")!
		head.contents = headImage.cgImage
		var sz = headImage.size
		head.bounds = CGRect(origin: .zero, size: sz)
		head.position = CGPoint(x: avatar.bounds.midX - 50, y: 0)
		//Add the head to the base layer
		avatar.addSublayer(head)
		
		//Scale to be applied to all bones to make the size proportionate to the head
		let boneScale: CGFloat = 0.65
		let scale = CATransform3DMakeScale(boneScale, boneScale, boneScale)
		
		//Create the humerus
		humerus = CALayer()
		let skelHumerus = UIImage(named: "Humerus")!
		humerus.contents = skelHumerus.cgImage
		sz = skelHumerus.size
		humerus.bounds = CGRect(origin: .zero, size: sz)
		humerus.position = CGPoint(x: avatar.bounds.midX + 60, y: 180)
		//set the anchorpoint to physical joint location
		humerus.anchorPoint = CGPoint(x: 0, y: 1)
		humerus.transform = scale
		//Add the humerus to the base layer
		avatar.addSublayer(humerus)
		
		//Create the Radius/Ulna
		radiusUlna = CALayer()
		let skelRadUlna = UIImage(named: "RadUlna")!
		radiusUlna.contents = skelRadUlna.cgImage
		sz = skelRadUlna.size
		radiusUlna.bounds = CGRect(origin: .zero, size: sz)
		radiusUlna.transform = CATransform3DMakeRotation(0.3, 0, 0, 1)
		radiusUlna.position = CGPoint(x: humerus.bounds.maxX - 10, y: 90)
		//set the anchorpoint to physical joint location
		radiusUlna.anchorPoint = CGPoint(x: 0, y: 0.5)
		//add this layer as a sublayer to the humerus
		humerus.addSublayer(radiusUlna)
		
		hand = CALayer()
		let skelhand = UIImage(named: "Hand")!
		hand.contents = skelhand.cgImage
		hand.bounds = CGRect(x: 0, y: 0, width: 180, height: 100)
		hand.position = CGPoint(x: radiusUlna.bounds.maxX - 15, y: radiusUlna.bounds.midY - 10)
		//set the anchorpoint to physical joint location
		hand.anchorPoint = CGPoint(x: 0, y: 0.5)
		var t2 = CATransform3DMakeScale(0.8, 0.8, 1)
		t2 = CATransform3DRotate(t2, 0.3, 0, 0, 1)
		hand.transform = t2
		//add this layer as a sublayer to the radius/ulna
		radiusUlna.addSublayer(hand)
		
		//Scale the entire avatar to fit on the screen
		avatar.transform = CATransform3DMakeScale(0.7, 0.7, 1)
	}
	
	func wave() {
		
		//Create the head bob animation
		let bob = CAKeyframeAnimation(keyPath: "transform")
		let r: [CATransform3D] = [CATransform3DMakeRotation(0.0, 0, 0, 1),
								  CATransform3DMakeRotation(-0.2, 0, 0, 1),
								  CATransform3DMakeRotation(0.2, 0, 0, 1)]
		bob.values = [NSValue(caTransform3D: r[0]),
					  NSValue(caTransform3D: r[1]),
					  NSValue(caTransform3D: r[0]),
					  NSValue(caTransform3D: r[2]),
					  NSValue(caTransform3D: r[0])
		]
		bob.repeatCount = Float.greatestFiniteMagnitude
		bob.duration = 1.75
		bob.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
		head.add(bob, forKey: nil)
		
		//Create the first rotation animation (the humerus)
		let r1 = CABasicAnimation(keyPath: "transform")
		var rot1 = CATransform3DMakeRotation(-0.5, 0, 0, 1)
		rot1 = CATransform3DConcat(rot1, humerus.transform)
		r1.toValue = NSValue(caTransform3D: rot1)
		r1.autoreverses = true
		r1.repeatCount = Float.greatestFiniteMagnitude
		r1.duration = 2.5
		r1.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
		humerus.add(r1, forKey: nil)
		
		//Create the second rotation animation (the radius/ulna)
		let r2 = CABasicAnimation(keyPath: "transform")
		var rot2 = CATransform3DMakeRotation(-0.7, 0, 0, 1)
		rot2 = CATransform3DConcat(rot2, radiusUlna.transform)
		r2.toValue = NSValue(caTransform3D: rot2)
		r2.autoreverses = true
		r2.repeatCount = Float.greatestFiniteMagnitude
		r2.duration = 2.5
		r2.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
		radiusUlna.add(r2, forKey: nil)
		
		//Create the third rotation animation (the hand)
		let r3 = CABasicAnimation(keyPath: "transform")
		var rot3 = CATransform3DMakeRotation(-0.9, 0, 0, 1)
		rot3 = CATransform3DConcat(rot3, hand.transform)
		r3.toValue = NSValue(caTransform3D: rot3)
		r3.autoreverses = true
		r3.repeatCount = Float.greatestFiniteMagnitude
		r3.duration = 2.5
		r3.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
		hand.add(r3, forKey: nil)
	}
}
