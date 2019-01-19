//
//  CustomView.swift
//  LineLayout_Swift
//
//  Created by Seyed Samad Gholamzadeh on 5/1/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

class CustomView: UIView {

    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
		UIColor.blue.setFill()
		UIRectFill(rect)
    }

}
