//
//  CompositeSubviewBasedApplicationCell.swift
//  AdvancedTableViewCells_Swift
//
//  Created by Seyed Samad Gholamzadeh on 6/25/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit


class CompositeSubviewBasedApplicationCellContentView: UIView {
	
	let MAX_RATING: Double = 5.0

	var cell: ApplicationCell
	
	var isHighlighted: Bool! = false {
		didSet {
			self.setNeedsDisplay()
		}
	}
	
	
	
	init(frame: CGRect, cell: ApplicationCell) {
		self.cell = cell
		
		super.init(frame: frame)
		self.isOpaque = true
		self.backgroundColor = cell.backgroundColor
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func draw(_ rect: CGRect) {
		
		cell.icon.draw(at: CGPoint(x: 11.0, y: 5.0))
		isHighlighted ? UIColor.white.set() : UIColor.black.set()
		let nameTextAttr = NSAttributedString(string: cell.name, attributes: [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 17.0)])
			nameTextAttr.draw(at: CGPoint(x: 81.0, y: 22.0))
		
		isHighlighted ? UIColor.white.set() : UIColor(white: 0.23, alpha: 1.0).set()
		let publisher = NSAttributedString(string: cell.publisher, attributes: [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 11.0)])
		publisher.draw(at: CGPoint(x: 81.0, y: 8.0))
		
		let ratingTextAttr = NSAttributedString(string: "\(cell.numRatings!) Ratings", attributes:  [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 11.0)])
		ratingTextAttr.draw(at: CGPoint(x: 157.0, y: 46.0))
		
		let priceTextAttr = NSAttributedString(string: cell.price, attributes: [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 11.0)])
		let priceSize = priceTextAttr.size()
		priceTextAttr.draw(at: CGPoint(x: self.bounds.size.width - priceSize.width - 8.0, y: 28.0))

		let ratingImageOrigin = CGPoint(x: 81.0, y: 45.0)
		let ratingBackgroundImage = UIImage(named: "StarsBackground")!
		ratingBackgroundImage.draw(at: ratingImageOrigin)
		
		let ratingForegroundImage = UIImage(named: "StarsForeground")!
		UIRectClip(CGRect(x: ratingImageOrigin.x, y: ratingImageOrigin.y, width: ratingForegroundImage.size.width * CGFloat(cell.rating / MAX_RATING), height: ratingForegroundImage.size.height))
		ratingForegroundImage.draw(at: ratingImageOrigin)
	}
	
}

class CompositeSubviewBasedApplicationCell: ApplicationCell {

	var cellContentView: UIView!
	
//	override var frame: CGRect {
//		didSet {
//			guard let contentSize = cellContentView?.bounds.size else { return }
//
//			UIView.setAnimationsEnabled(false)
//			self.cellContentView = cellContentView.resizableSnapshotView(from: cellContentView.bounds, afterScreenUpdates: false, withCapInsets: UIEdgeInsets(top: 0, left: (contentSize.width - 260.0)/2, bottom: 0, right: (contentSize.width - 260.0)/2))
//			UIView.setAnimationsEnabled(true)
//		}
//	}
	
	override var backgroundColor: UIColor? {
		didSet {
			super.backgroundColor = self.backgroundColor
			cellContentView?.backgroundColor = self.backgroundColor
		}
	}
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		
		cellContentView = CompositeSubviewBasedApplicationCellContentView(frame: self.contentView.bounds.insetBy(dx: 0, dy: 1), cell: self)
		cellContentView.autoresizingMask = UIViewAutoresizing(rawValue: UIViewAutoresizing.flexibleWidth.rawValue | UIViewAutoresizing.flexibleHeight.rawValue )
		cellContentView.contentMode = UIViewContentMode.redraw
		self.contentView.addSubview(cellContentView)
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func draw(_ rect: CGRect) {
		super.draw(rect)

	}
	
}
