//
//  ViewController.swift
//  PhotoFun
//
//  Created by Seyed Samad Gholamzadeh on 11/12/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

func subRect(_ image: UIImage, with rect: CGRect) -> UIImage? {
	UIGraphicsBeginImageContextWithOptions(rect.size, false, image.scale)
	let context = UIGraphicsGetCurrentContext()
	context?.addEllipse(in: CGRect(origin: .zero, size: rect.size))
	context?.clip()
	image.draw(at: CGPoint(x: -rect.origin.x, y: -rect.origin.y))
	let newImage = UIGraphicsGetImageFromCurrentImageContext()
	UIGraphicsEndImageContext()
	return newImage
}

class ViewController: UIViewController {

	@IBOutlet weak var imageView: UIImageView!
	@IBOutlet weak var blurView: UIVisualEffectView!
	var blurEffect: UIVisualEffect!
	
	override var prefersStatusBarHidden: Bool { return true }
	
	let face1Rect = CGRect(x: 98.0, y: 102, width: 343.0 - 98.0, height: 463.0 - 102.0)
	let face2Rect = CGRect(x: 349.0, y: 102.0, width: 530.0 - 349.0, height: 454.0 - 102.0)
	
	let faceCentroid = CGPoint(x: 375.0, y: 250.0)
	lazy var faceGuide: FaceLayoutGuide = FaceLayoutGuide(position: self.faceCentroid)
	lazy var gravityBehavior: UIFieldBehavior = UIFieldBehavior.radialGravityField(position: self.faceCentroid)
	lazy var animator: UIDynamicAnimator = {
		let animator = UIDynamicAnimator(referenceView: self.imageView)
		animator.addBehavior(self.gravityBehavior)
		return animator
	}()
	var exposingFace = false
	
	override func viewDidLoad() {
		super.viewDidLoad()

		faceGuide.attach(imageView, animator: animator)
		gravityBehavior.strength = 1.0
		faceGuide.addFieldBehavior(gravityBehavior)

		blurEffect = blurView.effect
		blurView.effect = nil

		blurView.leadingAnchor.constraint(equalTo: faceGuide.leadingAnchor).isActive = true
//		blurView.trailingAnchor.constraint(equalTo: faceGuide.trailingAnchor).isActive = true
//		blurView.topAnchor.constraint(equalTo: faceGuide.topAnchor).isActive = true
		blurView.bottomAnchor.constraint(equalTo: faceGuide.bottomAnchor).isActive = true

		let configureOverlayImage = { (_ originalImage:UIImage, _ faceRect: CGRect, _ referenceView: UIView, _ containerView: UIView) in
			let faceImage = subRect(originalImage, with: faceRect)
			let faceView = UIImageView(image: faceImage)
			faceView.translatesAutoresizingMaskIntoConstraints = false
			containerView.addSubview(faceView)
			faceView.topAnchor.constraint(equalTo: referenceView.topAnchor, constant: faceRect.minY).isActive = true
			faceView.leftAnchor.constraint(equalTo: referenceView.leftAnchor, constant: faceRect.minX).isActive = true
		}
		let originalImage: UIImage = imageView.image!
		configureOverlayImage(originalImage, face1Rect, imageView, blurView.contentView)
		configureOverlayImage(originalImage, face2Rect, imageView, blurView.contentView)

		let gesture = UITapGestureRecognizer(target: self, action: #selector(tapGesture(_:)))
		view.addGestureRecognizer(gesture)
		
		animator.setValue(true, forKey: "debugEnabled")
	}

	@objc func tapGesture(_ gesture: UITapGestureRecognizer) {
		exposingFace = !exposingFace
		gravityBehavior.strength = exposingFace ? -1.0 : 10.0
		self.view.setNeedsLayout()
	}
	
	override func viewDidLayoutSubviews() {
		let guideSize = faceGuide.layoutFrame.size
		let minEdge = min(guideSize.width, guideSize.height)
		if exposingFace {
			if blurView.effect == nil, minEdge > 50.0 {
				UIView.animate(withDuration: 0.5) {
					self.blurView.effect = self.blurEffect
				}
			}
		}
		else {
			if blurView.effect != nil, minEdge < 50.0 {
				UIView.animate(withDuration: 0.5) {
					self.blurView.effect = nil
				}
			}
		}
	}

}

