//
//  TTTRatingControl.swift
//  TicTacToeApp_Swift
//
//  Created by Seyed Samad Gholamzadeh on 7/12/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

let TTTRatingControlMinimumRating: Int = 0
let TTTRatingControlMaximumRating: Int = 4

class TTTRatingControl: UIControl {

	var rating: Int! {
		didSet {
			self.updateButtonImages()
		}
	}
	
	var backgroundImageView: UIImageView!
	var buttons: [UIButton]!
	
	static var backgroundImage: UIImage = {
		let cornerRadius: CGFloat = 4.0;
		let capSize: CGFloat = 2.0 * cornerRadius;
		let rectSize: CGFloat = 2.0 * capSize + 1.0;
		let rect: CGRect = CGRect(x: 0.0, y: 0.0, width: rectSize, height: rectSize)
		UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
		
		UIColor(white: 0.0, alpha: 0.2).set()
		let bezierPath = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius)
		bezierPath.fill()
		
		var image = UIGraphicsGetImageFromCurrentImageContext()!
		image = image.resizableImage(withCapInsets: UIEdgeInsets(top: capSize, left: capSize, bottom: capSize, right: capSize))
		image = image.withRenderingMode(.alwaysTemplate)
		UIGraphicsEndImageContext()
		
		return image
	}()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.rating = TTTRatingControlMinimumRating
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		if self.backgroundImageView == nil {
			self.backgroundImageView = UIImageView(image: TTTRatingControl.backgroundImage)
			self.addSubview(self.backgroundImageView)
		}
		
		self.backgroundImageView.frame = self.bounds
		
		if self.buttons == nil {
			var buttons: [UIButton] = []
			
			for rating in TTTRatingControlMinimumRating...TTTRatingControlMaximumRating {
				let button = UIButton(type: .custom)
				button.setImage(UIImage(named: "unselectedButton"), for: .normal)
				button.setImage(UIImage(named: "unselectedButton"), for: .highlighted)
				button.setImage(UIImage(named: "favoriteButton"), for: .selected)
				button.setImage(UIImage(named: "favoriteButton"), for: UIControlState(rawValue: UIControlState.selected.rawValue | UIControlState.highlighted.rawValue))
				button.tag = rating
				button.addTarget(self, action: #selector(touch(_:)), for: .touchUpInside)
				button.accessibilityLabel = NSLocalizedString("\(rating + 1) stars", comment: "\(rating + 1) stars")
				self.addSubview(button)
				buttons.append(button)
			}
			
			self.buttons = buttons
			self.updateButtonImages()
		}
		
		var buttonFrame = self.bounds
		let width = buttonFrame.size.width / CGFloat(TTTRatingControlMaximumRating - TTTRatingControlMinimumRating + 1)
		for (buttonIndex, button) in self.buttons.enumerated() {
			buttonFrame.size.width = round(width * CGFloat(buttonIndex + 1)) - buttonFrame.origin.x
			button.frame = buttonFrame
			buttonFrame.origin.x += buttonFrame.size.width
		}
	}
	
	func updateButtonImages() {
		guard self.buttons != nil else { return }
		for (buttonIndex, button) in self.buttons.enumerated() {
			button.isSelected = buttonIndex + TTTRatingControlMinimumRating <= self.rating
		}
	}
	
	@objc func touch(_ button: UIButton) {
		self.rating = button.tag
		self.sendActions(for: .valueChanged)
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
