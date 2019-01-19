//
//  RatingView.swift
//  AdvancedTableViewCells_Swift
//
//  Created by Seyed Samad Gholamzadeh on 6/25/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

class RatingView: UIView {
	
	let MAX_RATING: Double = 5.0
	
	var rating: Double! {
		didSet {
			foregroundImageView.frame = CGRect(x: 0.0, y: 0.0, width: backgroundImageView.frame.size.width * CGFloat(rating / MAX_RATING), height: foregroundImageView.bounds.size.height)
		}
	}
	var backgroundImageView: UIImageView!
	var foregroundImageView: UIImageView!
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		self.commonInit()
	}
	
	required init?(coder aDecoder: NSCoder) {
//		fatalError("init(coder:) has not been implemented")
		super.init(coder: aDecoder)
		
		self.commonInit()
	}
	
	func commonInit() {
		
		backgroundImageView = UIImageView(image: UIImage(named: "StarsBackground"))
		backgroundImageView.contentMode = .left
		self.addSubview(backgroundImageView)
		
		foregroundImageView = UIImageView(image: UIImage(named: "StarsForeground"))
		foregroundImageView.contentMode = .left
		foregroundImageView.clipsToBounds = true
		self.addSubview(foregroundImageView)
	}
}
