//
//  SliderCell.swift
//  CIFunHouseSwift
//
//  Created by Seyed Samad Gholamzadeh on 8/8/1396 AP.
//  Copyright © 1396 AP Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

protocol SliderCellDelegate {
	func sliderCellValueDidChange(cell: SliderCell)
}

class SliderCell: UITableViewCell {
	
	var titleLabel: UILabel
	var slider: UISlider
	var readingLabel: UILabel
	
	var delegate: SliderCellDelegate?
	
	static var cellHeight: CGFloat {
		return 62.0
	}
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		
		self.titleLabel = UILabel(frame: CGRect.zero)
		self.titleLabel.textAlignment = NSTextAlignment.left
		self.titleLabel.backgroundColor = UIColor.clear
		
		self.slider = UISlider(frame: CGRect.zero)
		
		self.readingLabel = UILabel(frame: CGRect.zero)

		super.init(style: style, reuseIdentifier: reuseIdentifier)
		self.contentView.addSubview(self.titleLabel)

		self.slider.addTarget(self, action: #selector(SliderCell.sliderValueChanged), for: UIControlEvents.valueChanged)
		self.contentView.addSubview(self.slider)
		
		self.readingLabel.textAlignment = NSTextAlignment.right
		self.readingLabel.backgroundColor = UIColor.clear
		self.contentView.addSubview(self.readingLabel)
		self.sliderValueChanged()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func layoutSubviews() {
		
		super.layoutSubviews()
		
		let cellWidth: CGFloat = self.bounds.size.width - 40.0
		let halfWidth: CGFloat = cellWidth / 2.0
		let x: CGFloat = 10.0
		let y: CGFloat = 4.0
		let height: CGFloat = 25.0
		
		titleLabel.frame = CGRect(x: x, y: y, width: halfWidth, height: height)
		readingLabel.frame = CGRect(x: x + halfWidth, y: y, width: halfWidth, height: height)
		slider.frame = CGRect(x: x, y: y + height, width: cellWidth, height: height)
	}
	
	@objc func sliderValueChanged() {
		self.delegate?.sliderCellValueDidChange(cell: self)
		let value = String(format: "%.2f", arguments: [slider.value])
		self.readingLabel.text = value
	}
	
	
}
