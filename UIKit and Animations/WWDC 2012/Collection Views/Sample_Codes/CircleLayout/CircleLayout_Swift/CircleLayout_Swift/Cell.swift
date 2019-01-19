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
		self.contentView.layer.cornerRadius = 35.0
		self.contentView.layer.borderWidth = 1.0
		self.contentView.layer.borderColor = UIColor.white.cgColor
		self.contentView.backgroundColor = UIColor.lightGray
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	
	
}
