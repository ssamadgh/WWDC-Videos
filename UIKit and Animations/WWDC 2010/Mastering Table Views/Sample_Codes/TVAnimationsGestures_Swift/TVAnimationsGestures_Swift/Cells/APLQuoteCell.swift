//
//  APLQuoteCellTableViewCell.swift
//  TVAnimationsGestures_Swift
//
//  Created by Seyed Samad Gholamzadeh on 6/22/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

class APLQuoteCell: UITableViewCell {

	@IBOutlet weak var characterLabel: UILabel!
	@IBOutlet weak var actAndSceneLabel: UILabel!
	@IBOutlet weak var quotationTextView: APLHighlightingTextView!
	
	var quoatation: APLPlay.APLQuotation! {
		didSet {
			if self.quoatation != oldValue {
				
				self.characterLabel.text = quoatation.character
				self.actAndSceneLabel.text = "Act \(quoatation.act!), Scene \(quoatation.scene!)"
				self.quotationTextView.text = quoatation.quotation
			}
		}
	}
	
	var longPressRecognizer: UILongPressGestureRecognizer! {
		
		didSet {
			if self.longPressRecognizer != oldValue {
				
				if oldValue != nil {
					self.removeGestureRecognizer(oldValue)
				}
				
				if self.longPressRecognizer != nil {
					self.addGestureRecognizer(self.longPressRecognizer)
				}
				
			}
		}
	}

}
