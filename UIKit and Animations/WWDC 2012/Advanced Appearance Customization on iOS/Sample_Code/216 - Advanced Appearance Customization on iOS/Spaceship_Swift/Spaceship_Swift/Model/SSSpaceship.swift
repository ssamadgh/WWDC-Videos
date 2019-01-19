//
//  SSSpaceship.swift
//  Spaceship_Swift
//
//  Created by Seyed Samad Gholamzadeh on 6/20/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import Foundation


let SSSpaceshipDidChangeNotification = "SSSpaceshipDidChangeNotification"

class SSSpaceship: NSObject, NSCoding {

	var frontDoor: SSDoor
	var backDoor: SSDoor
	var isPowerActive: Bool = false
	var artificialGravity: Bool
	var shield: Float
	var speed: Float
	var logs: Array<SSLog>
	
	override init() {
		self.frontDoor = SSDoor()
		self.backDoor = SSDoor()
		self.artificialGravity = true
		self.shield = 0.5
		self.speed = 0.5
		self.logs = []
		super.init()
	}
	
	required init?(coder aDecoder: NSCoder) {
		self.frontDoor = aDecoder.decodeObject(forKey: "frontDoor") as! SSDoor
		self.backDoor = aDecoder.decodeObject(forKey: "backDoor") as! SSDoor
		self.artificialGravity = aDecoder.decodeBool(forKey: "artificialGravity")
		self.shield = aDecoder.decodeFloat(forKey: "shield")
		self.speed = aDecoder.decodeFloat(forKey: "speed")
		self.logs = aDecoder.decodeObject(forKey: "logs") as! Array<SSLog>
		super.init()
	}

	
	func encode(with aCoder: NSCoder) {
		aCoder.encode(self.frontDoor, forKey: "frontDoor")
		aCoder.encode(self.backDoor, forKey: "backDoor")
		
		aCoder.encode(self.artificialGravity, forKey: "artificialGravity")
		aCoder.encode(self.shield, forKey: "shield")
		aCoder.encode(self.speed, forKey: "speed")
		aCoder.encode(self.logs, forKey: "logs")
	}
}
