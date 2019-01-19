//
//  SSTintedTheme.swift
//  Spaceship_Swift
//
//  Created by Seyed Samad Gholamzadeh on 4/27/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

struct SSTintedTheme: SSTheme {
	
	var baseTintColor: UIColor? {
		return UIColor(hue: 1.0/3.0, saturation: 0.75, brightness: 0.5, alpha: 1.0)
	}
	
	var accentTintColor: UIColor? {
		return UIColor(hue: 1.0/6.0, saturation: 1.0, brightness: 0.85, alpha: 1.0)
	}
	
	var mainColor: UIColor? {
		return self.accentTintColor
	}
	
	var backgroundColor: UIColor? {
		return UIColor(hue: 1.0/6.0, saturation: 0.15, brightness: 1.0, alpha: 1.0)
		
	}
	
	var switchOnColor: UIColor? {
		return self.baseTintColor
	}
	
	var switchTintColor: UIColor? {
		return self.accentTintColor
	}
}
