//
//  HybridSubviewBasedApplicationCell.swift
//  AdvancedTableViewCells_Swift
//
//  Created by Seyed Samad Gholamzadeh on 6/25/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

class HybridSubviewBasedApplicationCellContentView: UIView {
	
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
		
//		let priceTextAttr = NSAttributedString(string: cell.price, attributes: [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 11.0)])
//		let priceSize = priceTextAttr.size()
//		priceTextAttr.draw(at: CGPoint(x: self.bounds.size.width - priceSize.width - 8.0, y: 28.0))
		
		let ratingImageOrigin = CGPoint(x: 81.0, y: 45.0)
		let ratingBackgroundImage = UIImage(named: "StarsBackground")!
		ratingBackgroundImage.draw(at: ratingImageOrigin)
		
		let ratingForegroundImage = UIImage(named: "StarsForeground")!
		UIRectClip(CGRect(x: ratingImageOrigin.x, y: ratingImageOrigin.y, width: ratingForegroundImage.size.width * CGFloat(cell.rating / MAX_RATING), height: ratingForegroundImage.size.height))
		ratingForegroundImage.draw(at: ratingImageOrigin)
	}
	
}

class HybridSubviewBasedApplicationCell: ApplicationCell {

	var cellContentView: UIView!
	var priceLabel: UILabel!
	
	override var backgroundColor: UIColor? {
		didSet {
			super.backgroundColor = self.backgroundColor
			cellContentView?.backgroundColor = self.backgroundColor
			self.priceLabel.backgroundColor = self.backgroundColor
		}
	}

	override var price: String! {
		didSet {
			self.priceLabel?.text = price
		}
	}
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		
		cellContentView = HybridSubviewBasedApplicationCellContentView(frame: self.contentView.bounds.insetBy(dx: 0, dy: 1), cell: self)
		cellContentView.autoresizingMask = UIViewAutoresizing(rawValue: UIViewAutoresizing.flexibleWidth.rawValue | UIViewAutoresizing.flexibleHeight.rawValue )
		cellContentView.contentMode = UIViewContentMode.redraw
		self.contentView.addSubview(cellContentView)
		
		priceLabel = UILabel(frame: CGRect(x: self.contentView.bounds.size.width - 64.0, y: 25.0, width: 56.0, height: 21.0))
		priceLabel.textAlignment = NSTextAlignment.right
		priceLabel.font = UIFont.boldSystemFont(ofSize: 11.0)
		priceLabel.textColor = UIColor(white: 0.23, alpha: 1.0)
		priceLabel.highlightedTextColor = UIColor.white
		priceLabel.autoresizingMask = UIViewAutoresizing.flexibleLeftMargin
		self.contentView.addSubview(priceLabel)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
}
