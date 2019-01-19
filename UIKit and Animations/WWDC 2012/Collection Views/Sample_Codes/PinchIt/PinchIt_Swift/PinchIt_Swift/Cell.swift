//
//  Cell.swift
//  PinchIt_Swift
//
//  Created by Seyed Samad Gholamzadeh on 5/19/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

class Cell: UICollectionViewCell {
	
	var label: UILabel!
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		let label = UILabel(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height))
		
		label.autoresizingMask = UIViewAutoresizing(rawValue: UIViewAutoresizing.flexibleWidth.rawValue | UIViewAutoresizing.flexibleHeight.rawValue)
		label.textAlignment = .center
		label.font = UIFont.boldSystemFont(ofSize: 50.0)
		label.backgroundColor = UIColor.gray
		label.textColor = UIColor.black
		self.contentView.addSubview(label)
		self.label = label
		self.contentView.layer.borderWidth = 1.0
		self.contentView.layer.borderColor = UIColor.white.cgColor
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
