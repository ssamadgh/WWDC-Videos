//
//  TTTCountView.swift
//  TicTacToeApp_Swift
//
//  Created by Seyed Samad Gholamzadeh on 7/12/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

class TTTCountView: UIView {

	let TTTCountViewLineWidth: CGFloat = 1.0;
	let TTTCountViewLineMargin: CGFloat = 4.0;
	let TTTCountViewLineGroupCount: Int = 5;

	var count: Int! {
		didSet {
			var oldRect = CGRect.zero
			if oldValue != nil {
				oldRect = self.rect(for: oldValue)
			}
			let newRect = self.rect(for: self.count)
			let dirtyRect = oldRect.union(newRect)
			self.setNeedsDisplay(dirtyRect)
		}
	}
	

	override init(frame: CGRect) {
		super.init(frame: frame)
		 self.isOpaque = false
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func draw(_ rect: CGRect) {
		self.tintColor.set()
		let bounds = self.bounds
		var x = bounds.maxX - TTTCountViewLineWidth
		
		for n in 0..<self.count {
			x -= TTTCountViewLineMargin
			
			if CGFloat(n + 1).truncatingRemainder(dividingBy: CGFloat(TTTCountViewLineGroupCount)) == 0 {
				// Draw the diagonal line
				let path = UIBezierPath()
				path.move(to: CGPoint(x: x + 0.5 * TTTCountViewLineWidth, y: bounds.minY + 0.5 * TTTCountViewLineWidth))
				path.addLine(to: CGPoint(x: x + 0.5 * TTTCountViewLineWidth + CGFloat(TTTCountViewLineGroupCount) * TTTCountViewLineMargin, y: bounds.maxY - 0.5 * TTTCountViewLineWidth))
				path.stroke()
			}
			else {
				// Draw a vertical line
				var lineRect = bounds
				lineRect.origin.x = x
				lineRect.size.width = TTTCountViewLineWidth
				UIRectFill(lineRect)

			}
		}
	}
	
	func rect(for count: Int) -> CGRect {
		let bounds = self.bounds
		var rect = bounds
		rect.size.width = TTTCountViewLineWidth + TTTCountViewLineMargin * CGFloat(count)
		rect.origin.x += bounds.size.width - rect.size.width
		return rect
	}
	
	override func tintColorDidChange() {
		super.tintColorDidChange()
		self.setNeedsDisplay(self.rect(for: self.count))
	}
	
	//MARK: - Accessibility
	override var isAccessibilityElement: Bool {
		get {
			return true
		}
		
		set {
			super.isAccessibilityElement = newValue
		}
	}
	
	override var accessibilityLabel: String? {
		get {
			return "\(self.count)"
		}
		
		set {
			super.accessibilityLabel = newValue
		}
	}
	
	override var accessibilityTraits: UIAccessibilityTraits {
		get {
			return UIAccessibilityTraitImage
		}
		
		set {
			super.accessibilityTraits = newValue
		}
	}
	
	
}
