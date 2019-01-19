//
//  MainView.swift
//  MotionAlongAPath_Swift
//
//  Created by Seyed Samad Gholamzadeh on 3/6/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

class MainView: UIView {
	
	var path: CGPath? {
		didSet {
			self.setNeedsDisplay()
		}
	}

    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
		
		if let path = self.path {
			
			let ctx = UIGraphicsGetCurrentContext()
			
				ctx?.setStrokeColor(UIColor.black.cgColor)
			ctx?.addPath(self.path!)

			ctx?.setLineWidth(2)
			ctx?.setLineCap(CGLineCap.round)
			ctx?.drawPath(using: CGPathDrawingMode.stroke)
		}
		
    }

}
