//
//  APLHighlightingTextView.swift
//  TVAnimationsGestures_Swift
//
//  Created by Seyed Samad Gholamzadeh on 6/22/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

class APLHighlightingTextView: UITextView {

	var isHighlighted: Bool = false {
		didSet {
			if isHighlighted != oldValue {
				// Adjust the text color based on highlighted state.
				self.textColor = isHighlighted ? UIColor.white : UIColor.black
			}
		}
	}
	

}
