//
//  APLPlay.swift
//  TVAnimationsGestures_Swift
//
//  Created by Seyed Samad Gholamzadeh on 6/22/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import Foundation

struct APLPlay: Decodable {
	
	var name: String!
	var quotations: Array<APLQuotation>
	
	private enum CodingKeys: String, CodingKey {
		case name = "playName"
		case quotations
	}
	
	struct APLQuotation: Equatable, Decodable {
		
		static func == (lhs: APLPlay.APLQuotation, rhs: APLPlay.APLQuotation) -> Bool {
			return lhs.character == rhs.character && lhs.act == rhs.act && lhs.scene == rhs.scene && lhs.quotation == rhs.quotation
		}
		
		var character: String!
		var act: Int!
		var scene: Int!
		var quotation: String!
		
	}

}
