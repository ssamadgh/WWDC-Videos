//
//  Data.swift
//  AdvancedTableViewCells_Swift
//
//  Created by Seyed Samad Gholamzadeh on 6/25/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import Foundation


struct Data: Codable {
	
	let publisher: String
	let name: String
	let numRatings: Int
	let rating: Double
	let price: String
	let icon: String
	
	private enum CodingKeys: String, CodingKey {
		case publisher = "Publisher"
		case name = "Name"
		case numRatings = "NumRatings"
		case rating = "Rating"
		case price = "Price"
		case icon = "Icon"
	}

}
