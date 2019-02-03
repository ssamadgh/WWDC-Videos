//
//  ViewController.swift
//  Touches
//
//  Created by Seyed Samad Gholamzadeh on 10/29/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIGestureRecognizerDelegate {

	@IBOutlet weak var firstPieceView: UIView!
	@IBOutlet weak var secondPieceView: UIView!
	@IBOutlet weak var thirdPieceView: UIView!

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		
		self.addGestureRecognizers(to: firstPieceView)
		self.addGestureRecognizers(to: secondPieceView)
		self.addGestureRecognizers(to: thirdPieceView)

	}

	
	func addGestureRecognizers(to view: UIView) {
		let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panPiece(_:)))
		panGesture.delegate = self
		view.addGestureRecognizer(panGesture)
		
		let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(scalePiece(_:)))
		pinchGesture.delegate = self
		view.addGestureRecognizer(pinchGesture)
		
		let rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(rotatePiece(_:)))
		rotationGesture.delegate = self
		view.addGestureRecognizer(rotationGesture)

	}
	
	@objc func panPiece(_ gestureRecognizer: UIPanGestureRecognizer) {
		guard let piece = gestureRecognizer.view else { return }
		
		self.adjustAnchorPoint(for: gestureRecognizer)
		
		if gestureRecognizer.state == .began || gestureRecognizer.state == .changed {
			let center = piece.center
			let translation = gestureRecognizer.translation(in: piece.superview)
			piece.center = CGPoint(x: center.x + translation.x, y: center.y + translation.y)
			gestureRecognizer.setTranslation(CGPoint.zero, in: piece.superview)
		}
	}
	
	@objc func scalePiece( _ gestureRecognizer: UIPinchGestureRecognizer) {
		guard let piece = gestureRecognizer.view else { return }
		
		self.adjustAnchorPoint(for: gestureRecognizer)

		if gestureRecognizer.state == .began || gestureRecognizer.state == .changed {
			let transform = piece.transform
			let scale = gestureRecognizer.scale
			piece.transform = transform.scaledBy(x: scale, y: scale)
			gestureRecognizer.scale = 1
		}
		
	}
	
	@objc func rotatePiece(_ gestureRecognizer: UIRotationGestureRecognizer) {
		guard let piece = gestureRecognizer.view else { return }
		
		self.adjustAnchorPoint(for: gestureRecognizer)

		if gestureRecognizer.state == .began || gestureRecognizer.state == .changed {
			let transform = piece.transform
			let rotation = gestureRecognizer.rotation
			piece.transform = transform.rotated(by: rotation)
			gestureRecognizer.rotation = 0
		}
	}
	
	func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
		return gestureRecognizer.view == otherGestureRecognizer.view
	}
	
	func adjustAnchorPoint(for gestureRecognizer: UIGestureRecognizer) {
		
		if gestureRecognizer.state == .began {
			guard let piece = gestureRecognizer.view else { return }
			let locationInView = gestureRecognizer.location(in: piece)
			print("location in view, ", locationInView)
			let locationInSuperview = gestureRecognizer.location(in: piece.superview)
			piece.layer.anchorPoint = CGPoint(x: locationInView.x / piece.bounds.width, y: locationInView.y / piece.bounds.size.height)
			piece.center = locationInSuperview
		}
		
	}


}

