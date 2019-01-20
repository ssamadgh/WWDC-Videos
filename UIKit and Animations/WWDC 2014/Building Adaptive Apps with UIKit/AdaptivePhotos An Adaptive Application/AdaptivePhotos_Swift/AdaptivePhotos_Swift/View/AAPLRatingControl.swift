/*
Copyright (C) 2014 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:

A control that allows viewing and editing a rating.

*/

import UIKit

let AAPLRatingControlMinimumRating: Int = 0
let AAPLRatingControlMaximumRating: Int = 4

class AAPLRatingControl: UIControl {

	var rating: Int! {
		didSet {
		self.updateImageViews()
		}
	}
	
	var backgroundView: UIVisualEffectView!
	var imageViews: [UIImageView]!
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		self.rating = AAPLRatingControlMinimumRating
		
		let effect = UIBlurEffect(style: .light)
		self.backgroundView = UIVisualEffectView(effect: effect)
		self.backgroundView.contentView.backgroundColor = UIColor(white: 0.7, alpha: 0.3)
		self.addSubview(self.backgroundView)
		
		var imageViews: [UIImageView] = []
		
		for rating in AAPLRatingControlMinimumRating...AAPLRatingControlMaximumRating {
			
			let imageView = UIImageView()
			imageView.isUserInteractionEnabled = true
			
			// Set up our image view's images
			imageView.image = UIImage(named: "ratingInactive")
			imageView.highlightedImage = UIImage(named: "ratingActive")
			imageView.accessibilityLabel = String(format: NSLocalizedString("%d stars", comment: "%d stars"), rating + 1)
			self.addSubview(imageView)
			imageViews.append(imageView)
		}
		
		self.imageViews = imageViews
		self.updateImageViews()
		self.setupConstraints()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func setupConstraints() {
		self.backgroundView.translatesAutoresizingMaskIntoConstraints = false
		let views = ["backgroundView" : self.backgroundView!]
		self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[backgroundView]|", options: NSLayoutFormatOptions(), metrics: nil, views: views))
		self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[backgroundView]|", options: NSLayoutFormatOptions(), metrics: nil, views: views))
		
		var lastImageView: UIImageView? = nil
		
		for imageView in self.imageViews {
			imageView.translatesAutoresizingMaskIntoConstraints = false
			
			let currentImageViews: [String : UIImageView] = lastImageView != nil ? ["imageView" : imageView, "lastImageView" : lastImageView!] : ["imageView" : imageView]
			
			self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-4-[imageView]-4-|", options: NSLayoutFormatOptions(), metrics: nil, views: currentImageViews))
			self.addConstraint(NSLayoutConstraint.init(item: imageView, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: imageView, attribute: NSLayoutAttribute.height, multiplier: 1.0, constant: 0.0))
			
			if lastImageView != nil {
				self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "[lastImageView][imageView(==lastImageView)]", options: NSLayoutFormatOptions(), metrics: nil, views: currentImageViews))
			}
			else {
				self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-4-[imageView]", options: NSLayoutFormatOptions(), metrics: nil, views: currentImageViews))
			}
			
			lastImageView = imageView
		}
		
		let currentImageViews = ["lastImageView" : lastImageView!]
		self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "[lastImageView]-4-|", options: NSLayoutFormatOptions(), metrics: nil, views: currentImageViews))

	}
	
	func updateImageViews() {
		for (imageViewIndex, imageView) in self.imageViews.enumerated() {
			imageView.isHighlighted = (imageViewIndex + AAPLRatingControlMinimumRating <= self.rating)
		}
	}
	
	//MARK: - Touches
	
	func updateRatingWithTouches(_ touches: Set<UITouch>, with event: UIEvent?) {
		
		guard let touch = touches.first else { return }
		let position = touch.location(in: self)
		guard let touchedView = self.hitTest(position, with: event) else { return }
		
		if self.imageViews.contains(touchedView as! UIImageView) {
			self.rating = AAPLRatingControlMinimumRating + self.imageViews.index(of: touchedView as! UIImageView)!
			self.sendActions(for: .valueChanged)
		}
	}
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		self.updateRatingWithTouches(touches, with: event)
	}
	
	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		self.updateRatingWithTouches(touches, with: event)
	}
	
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		
	}
	
	override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
		
	}
	
	//MARK: - Accessibility
	override var isAccessibilityElement: Bool {
		get {
			return false
		}
		
		set {
			super.isAccessibilityElement = newValue
		}
	}
	
}
