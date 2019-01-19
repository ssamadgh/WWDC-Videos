//
//  Cell.swift
//  LineLayout_Swift
//
//  Created by Seyed Samad Gholamzadeh on 4/30/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

class Cell: UICollectionViewCell {
	
	var label: UILabel!
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.label = UILabel(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
		self.label.autoresizingMask = UIViewAutoresizing(rawValue: UIViewAutoresizing.flexibleWidth.rawValue | UIViewAutoresizing.flexibleHeight.rawValue)
		self.label.textAlignment = .center
		self.label.font = UIFont.boldSystemFont(ofSize: 50)
		self.backgroundColor = UIColor.lightGray
		self.label.textColor = UIColor.black
		self.contentView.addSubview(self.label)
		self.contentView.layer.borderWidth = 1.0
		self.contentView.layer.borderColor = UIColor.white.cgColor
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	
	
}
