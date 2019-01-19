//
//  Cards.swift
//  Animation101
//
//  Created by Seyed Samad Gholamzadeh on 3/7/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

class Cards: NSObject {

	static var spadePip: CAShapeLayer {
		
		let spade = CAShapeLayer()
		spade.bounds = CGRect(origin: .zero, size:  CGSize(width: 48, height: 64))
		
		let path = CGMutablePath()

		var p1 = CGPoint(x: 24, y: 15)
		var p2 = CGPoint(x: 4, y: 10)
		var p3 = CGPoint(x: 4, y: 30)

		path.move(to: CGPoint(x: 24, y: 4))
		
		path.addCurve(to: p3, control1: p1, control2: p2)
		
		p1 = CGPoint(x: 4, y: 40)
		p2 = CGPoint(x: 14, y: 50)
		p3 = CGPoint(x: 22, y: 40)
		path.addCurve(to: p3, control1: p1, control2: p2)

		p3 = CGPoint(x: 9, y: 60)
		path.addLine(to: p3)
		p3 = CGPoint(x: 39, y: 60)
		path.addLine(to: p3)
		p3 = CGPoint(x: 26, y: 40)
		path.addLine(to: p3)
		
		// Now reverse the two curves above
		p2 = CGPoint(x: 44, y: 40)
		p1 = CGPoint(x: 34, y: 50)
		p3 = CGPoint(x: 44, y: 30)
		path.addCurve(to: p3, control1: p1, control2: p2)
		
		p2 = CGPoint(x: 24, y: 15)
		p1 = CGPoint(x: 44, y: 10)
		p3 = CGPoint(x: 24, y: 2)
		path.addCurve(to: p3, control1: p1, control2: p2)

		path.closeSubpath()
		
		let space = CGColorSpaceCreateDeviceRGB()
		let components: [CGFloat] = [0.1, 0.1, 0.1, 0.98]
		let almostBlack = CGColor(colorSpace: space, components: components)
		
		spade.fillColor = almostBlack
		spade.path = path
		
		return spade

	}
	
}
