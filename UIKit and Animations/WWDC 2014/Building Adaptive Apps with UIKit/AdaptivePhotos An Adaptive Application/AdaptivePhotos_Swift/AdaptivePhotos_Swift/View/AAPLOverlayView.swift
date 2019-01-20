/*
Copyright (C) 2014 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:

A view that shows a textual overlay whose margins change with its vertical size class.

*/

import UIKit

class AAPLOverlayView: UIView {

	var text: String! {
		get {
			return self.label.text
		}
		
		set {
			self.label.text = newValue
			self.invalidateIntrinsicContentSize()
		}
	}
	
	private var label: UILabel!
	
	override var intrinsicContentSize: CGSize {
		
		var size = self.label.intrinsicContentSize
		
		// Add a horizontal margin whose size depends on our horizontal size class
		if self.traitCollection.horizontalSizeClass == .compact {
			size.width += 4.0
		} else {
			size.width += 40.0
		}
		
		
		// Add a vertical margin whose size depends on our vertical size class
		if self.traitCollection.verticalSizeClass == .compact {
			size.height += 4.0
		} else {
			size.height += 40.0
		}
		return size
	}
	
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		if self.traitCollection.verticalSizeClass != previousTraitCollection?.verticalSizeClass || self.traitCollection.horizontalSizeClass != previousTraitCollection?.horizontalSizeClass {
			// If our size class has changed, then our intrinsic content size will need to be updated
			self.invalidateIntrinsicContentSize()
		}
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		let effect = UIBlurEffect(style: .light)
		let backgroundView = UIVisualEffectView(effect: effect)
		backgroundView.contentView.backgroundColor = UIColor(white: 0.7, alpha: 0.3)
		backgroundView.translatesAutoresizingMaskIntoConstraints = false
		self.addSubview(backgroundView)
		
		let views = ["backgroundView" : backgroundView]
		self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[backgroundView]|", options: NSLayoutFormatOptions(), metrics: nil, views: views))
		self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[backgroundView]|", options: NSLayoutFormatOptions(), metrics: nil, views: views))

		self.label = UILabel()
		self.label.translatesAutoresizingMaskIntoConstraints = false
		self.addSubview(self.label)
		
		self.addConstraint(NSLayoutConstraint(item: self.label, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.centerX, multiplier: 1.0, constant: 0.0))
		self.addConstraint(NSLayoutConstraint(item: self.label, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.centerY, multiplier: 1.0, constant: 0.0))
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}



