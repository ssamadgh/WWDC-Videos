//
//  SSDoor.swift
//  Spaceship_Swift
//
//  Created by Seyed Samad Gholamzadeh on 6/20/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import Foundation

class SSDoor: NSObject, NSCoding {
	
	var isLocked: Bool = false {
		didSet {
			if isLocked != oldValue {
				if isLocked {
					self.isOpen = false
				}
			}
		}
	}
	
	var isOpen: Bool = false
	
	override init() {
		super.init()
	}
	
	required init?(coder aDecoder: NSCoder) {
		self.isLocked = aDecoder.decodeBool(forKey: "locked")
		self.isOpen = aDecoder.decodeBool(forKey: "open")
		super.init()
	}
	
	func encode(with aCoder: NSCoder) {
		aCoder.encode(self.isLocked, forKey: "locked")
		aCoder.encode(self.isOpen, forKey: "open")

	}
	
}
