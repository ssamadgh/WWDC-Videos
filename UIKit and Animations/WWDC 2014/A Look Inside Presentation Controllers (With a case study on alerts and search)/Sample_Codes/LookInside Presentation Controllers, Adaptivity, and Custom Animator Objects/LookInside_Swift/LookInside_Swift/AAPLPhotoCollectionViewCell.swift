//
//  AAPLPhotoCollectionViewCell.swift
//  LookInside_Swift
//
//  Created by Seyed Samad Gholamzadeh on 7/18/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

class AAPLPhotoCollectionViewCell: UICollectionViewCell {
	
	var imageView: UIImageView!
	var image: UIImage? {
		
		get {
			return self.imageView.image
		}
		
		set {
			self.imageView.image = newValue
		}
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		self.imageView = UIImageView()
		self.imageView.contentMode = .scaleAspectFill
		self.contentView.addSubview(self.imageView)
		self.contentView.clipsToBounds = true
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		self.imageView.frame = self.contentView.bounds
	}
}
