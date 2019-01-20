//
//  TTTMessage.swift
//  TicTacToeApp_Swift
//
//  Created by Seyed Samad Gholamzadeh on 7/9/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

class TTTMessage: NSObject, NSCoding {

	let TTTMessageEncodingKeyText = "text"
	let TTTMessageEncodingKeyIcon = "icon"

	var text: String!
	var icon: TTTProfileIcon!
	
	override init() {
		super.init()
	}
	
	required init?(coder aDecoder: NSCoder) {
		self.text = aDecoder.decodeObject(forKey: TTTMessageEncodingKeyText) as! String
		self.icon = TTTProfileIcon(rawValue: aDecoder.decodeInteger(forKey: TTTMessageEncodingKeyIcon))
	}
	
	func encode(with aCoder: NSCoder) {
		aCoder.encode(self.text, forKey: TTTMessageEncodingKeyText)
		aCoder.encode(self.icon.rawValue, forKey: TTTMessageEncodingKeyIcon)
	}
}
