//
//  ApplicationCell.swift
//  AdvancedTableViewCells_Swift
//
//  Created by Seyed Samad Gholamzadeh on 6/25/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

class ApplicationCell: UITableViewCell {

	var useDarkBackground: Bool = false {
		didSet {
			if self.useDarkBackground != oldValue || self.backgroundView == nil {
				
				let backgroundImagePath = Bundle.main.url(forResource: useDarkBackground ? "DarkBackground" : "LightBackground", withExtension: "png")
				let backgroundImage = UIImage(named: useDarkBackground ? "DarkBackground" : "LightBackground")?.stretchableImage(withLeftCapWidth: 0, topCapHeight: 1)
				self.backgroundView = UIImageView(image: backgroundImage)
				self.backgroundView?.autoresizingMask = UIViewAutoresizing(rawValue:UIViewAutoresizing.flexibleWidth.rawValue | UIViewAutoresizing.flexibleHeight.rawValue)
				self.backgroundView?.frame = self.bounds
				
			}
		}
	}
	
	var icon: UIImage!
	var publisher: String!
	var name: String!
	var rating: Double!
	var numRatings: Int!
	var price: String!

}
