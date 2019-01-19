//
//  SSLog.swift
//  Spaceship_Swift
//
//  Created by Seyed Samad Gholamzadeh on 6/20/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import Foundation

class SSLog: NSObject, NSCoding {
	
	static var formatter: DateFormatter? = nil
	
	var date: Date
	var attributedText: NSAttributedString
	
	var dateDescription: String? {
		SSLog.formatter = DateFormatter()
		SSLog.formatter?.timeStyle = .short
		SSLog.formatter?.dateStyle = .short
		
		return SSLog.formatter?.string(from: self.date)
	}
	
	override init() {
		self.date = Date()
		self.attributedText = NSAttributedString(string: "Hello world")
		super.init()
	}
	
	
	required init?(coder aDecoder: NSCoder) {
		self.date = aDecoder.decodeObject(forKey: "date") as! Date
		self.attributedText = aDecoder.decodeObject(forKey: "attributedText") as! NSAttributedString
		
		super.init()
		
	}
	
	func encode(with aCoder: NSCoder) {
		
		aCoder.encode(self.date, forKey: "date")
		aCoder.encode(self.attributedText, forKey: "attributedText")

	}
	
	

}
