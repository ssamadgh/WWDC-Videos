//
//  SSSmallButton.swift
//  Spaceship_Swift
//
//  Created by Seyed Samad Gholamzadeh on 6/20/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

class SSSmallButton: UIButton {
	
	override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
		var bounds = self.bounds
		let widthDelta = 44.0 - bounds.size.width
		let heightDelta = 44.0 - bounds.size.height
		// Enlarge the effective bounds to be 44 x 44 pt
		bounds = bounds.insetBy(dx: -0.5*widthDelta, dy: -0.5*heightDelta)
		return bounds.contains(point)
	}
	
	
}
