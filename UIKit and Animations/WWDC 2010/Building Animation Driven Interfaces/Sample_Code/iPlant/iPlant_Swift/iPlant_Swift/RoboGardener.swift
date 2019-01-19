//
//  RoboGardener.swift
//  iPlant_Swift
//
//  Created by Seyed Samad Gholamzadeh on 3/6/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

private var GwaterLevel: CGFloat = -1.0

class RoboGardener: NSObject {

	
	override init() {
		super.init()
		
		if waterLevel == -1.0 {
			waterLevel = 100.0
		}
	}
	
	/*
	Lower the water level
	*/
	func waterPlant() {
		waterLevel -= 30.0
		
		if waterLevel < 0.0 {
			waterLevel = 0.0
		}
	}
	
	/*
	Return the water level
	*/
	var waterLevel: CGFloat {
		get {
			return GwaterLevel
		}
		
		set {
			GwaterLevel = newValue
		}
		
	}
}
