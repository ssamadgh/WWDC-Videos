/*
Copyright (C) 2014 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:

A view controller that shows a photo and its metadata.

*/

import UIKit

class AAPLPhotoViewController: UIViewController {

	var photo: AAPLPhoto! {
		didSet {
			self.updatePhoto()
		}
	}
	
	var imageView: UIImageView!
	var overlayButton: AAPLOverlayView!
	var ratingControl: AAPLRatingControl!
	
	override var aapl_containedPhoto: AAPLPhoto? {
		return self.photo
	}
	
	override func loadView() {
		super.loadView()
		
		self.view = UIView()
		view.backgroundColor = .white

		let imageView = UIImageView()
		imageView.contentMode = .scaleAspectFit
		imageView.translatesAutoresizingMaskIntoConstraints = false
		self.imageView = imageView
		self.view.addSubview(imageView)

		let ratingControl = AAPLRatingControl()
		ratingControl.translatesAutoresizingMaskIntoConstraints = false
		ratingControl.addTarget(self, action: #selector(changeRating(_:)), for: .valueChanged)
		self.ratingControl = ratingControl
		self.view.addSubview(ratingControl)
		
		let overlayButton = AAPLOverlayView()
		overlayButton.translatesAutoresizingMaskIntoConstraints = false
		self.overlayButton = overlayButton
		self.view.addSubview(overlayButton)
		
		self.updatePhoto()
		
		let views = ["imageView" : imageView, "ratingControl" : ratingControl, "overlayButton" : overlayButton]
		self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[imageView]|", options: NSLayoutFormatOptions(), metrics: nil, views: views))
		self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[imageView]|", options: NSLayoutFormatOptions(), metrics: nil, views: views))
		self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "[ratingControl]-|", options: NSLayoutFormatOptions(), metrics: nil, views: views))
		self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "[overlayButton]-|", options: NSLayoutFormatOptions(), metrics: nil, views: views))
		self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[overlayButton]-[ratingControl]-(20)-|", options: NSLayoutFormatOptions(), metrics: nil, views: views))
		
		var constraints: [NSLayoutConstraint] = []
		constraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "|-(>=20)-[ratingControl]", options: NSLayoutFormatOptions(), metrics: nil, views: views))
		constraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "|-(>=20)-[overlayButton]", options: NSLayoutFormatOptions(), metrics: nil, views: views))
		for constraint in constraints {
			constraint.priority = UILayoutPriority.required - 1
		}
		self.view.addConstraints(constraints)
	}
	
	@objc func changeRating(_ sender: AAPLRatingControl) {
		self.photo.rating = sender.rating
	}
	
	func updatePhoto() {
		self.imageView?.image = self.photo.image
		self.overlayButton?.text = self.photo.comment
		self.ratingControl?.rating = self.photo.rating
	}
	
}
