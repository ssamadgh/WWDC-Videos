/*
  TemperatureCellTableViewCell.swift
  Recipes_Swift

  Created by Seyed Samad Gholamzadeh on 3/2/18.
  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.

Abstract:
A table view cell that displays temperature in Centigrade, Fahrenheit, and Gas Mark.
*/


import UIKit

class TemperatureCell: UITableViewCell {

	@IBOutlet weak var cLabel: UILabel!
	@IBOutlet weak var fLabel: UILabel!
	@IBOutlet weak var gLabel: UILabel!
	
	func setTemperatureDataFrom(dictionary temperatureDictionary: [String : String]) {
		
		// Update text in labels from the dictionary.
		self.cLabel.text = temperatureDictionary["c"]
		self.fLabel.text = temperatureDictionary["f"]
		self.gLabel.text = temperatureDictionary["g"]

	}
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
