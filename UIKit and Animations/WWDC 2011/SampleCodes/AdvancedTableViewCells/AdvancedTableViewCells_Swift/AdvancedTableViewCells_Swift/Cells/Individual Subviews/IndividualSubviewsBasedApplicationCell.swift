//
//  IndividualSubviewsBasedApplicationCell.swift
//  AdvancedTableViewCells_Swift
//
//  Created by Seyed Samad Gholamzadeh on 6/25/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

class IndividualSubviewsBasedApplicationCell: ApplicationCell {

	@IBOutlet weak var iconView: UIImageView!
	@IBOutlet weak var publisherLabel: UILabel!
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var ratingView: RatingView!
	@IBOutlet weak var numRatingsLabel: UILabel!
	@IBOutlet weak var priceLabel: UILabel!

	
	override var backgroundColor: UIColor? {
		didSet {
			iconView?.backgroundColor = backgroundColor
			publisherLabel?.backgroundColor = backgroundColor
			nameLabel?.backgroundColor = backgroundColor
			ratingView?.backgroundColor = backgroundColor
			numRatingsLabel?.backgroundColor = backgroundColor
			priceLabel?.backgroundColor = backgroundColor
		}
	}
	
	override var icon: UIImage! {
		didSet {
			self.iconView?.image = icon
		}
	}
	
	override var publisher: String! {
		didSet {
			self.publisherLabel?.text = publisher
		}
	}
	
	override var rating: Double! {
		didSet {
			self.ratingView?.rating = rating
		}
	}
	
	override var numRatings: Int! {
		didSet {
			self.numRatingsLabel?.text = "\(numRatings) Ratings"
		}
	}
	
	override var name: String! {
		didSet {
			self.nameLabel?.text = name
		}
	}
	
	override var price: String! {
		didSet {
			self.priceLabel?.text = price
		}
	}
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
		
    }
	
}
