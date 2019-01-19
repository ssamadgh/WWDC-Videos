//
//  APLSectionHeaderView.swift
//  TVAnimationsGestures_Swift
//
//  Created by Seyed Samad Gholamzadeh on 6/22/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

protocol SectionHeaderViewDelegate {
	
	func sectionHeaderView(_ sectionHeaderView: APLSectionHeaderView, sectionOpened section: Int)
	func sectionHeaderView(_ sectionHeaderView: APLSectionHeaderView, sectionClosed section: Int)

}

extension SectionHeaderViewDelegate {
	
	func sectionHeaderView(_ sectionHeaderView: APLSectionHeaderView, sectionOpened section: Int) {}
	func sectionHeaderView(_ sectionHeaderView: APLSectionHeaderView, sectionClosed section: Int) {}

	
}


class APLSectionHeaderView: UITableViewHeaderFooterView {

	var delegate: SectionHeaderViewDelegate!
	
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var disclosureButton: UIButton!
	
	var section: Int!
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		// set the selected image for the disclosure button
		self.disclosureButton.setImage(UIImage(named: "carat-open"), for: .selected)
		
		// set up the tap gesture recognizer
		let tpaGesture = UITapGestureRecognizer(target: self, action: #selector(toggleOpen(_:)))
		self.addGestureRecognizer(tpaGesture)

	}
	

	@IBAction func toggleOpen(_ sender: Any) {
		self.toggleOpenWithUserAction(true)
	}
	
	func toggleOpenWithUserAction(_ userAction: Bool) {
		
		// toggle the disclosure button state
		self.disclosureButton.isSelected = !self.disclosureButton.isSelected

		// if this was a user action, send the delegate the appropriate message
		if userAction {
			if self.disclosureButton.isSelected {
				self.delegate?.sectionHeaderView(self, sectionOpened: self.section)
			}
			else {
				self.delegate?.sectionHeaderView(self, sectionClosed: self.section)
			}
		}
	}
	
}
