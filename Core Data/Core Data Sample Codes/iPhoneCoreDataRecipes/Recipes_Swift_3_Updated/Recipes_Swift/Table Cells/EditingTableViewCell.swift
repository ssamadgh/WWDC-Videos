/*
  EditingTableViewCell.swift
  Recipes_Swift

  Created by Seyed Samad Gholamzadeh on 2/28/18.
  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.

Abstract:
A table view cell that displays a label and a text field so that a value can be edited. The user interface is loaded from a nib file.
*/


import UIKit

class EditingTableViewCell: UITableViewCell {

	@IBOutlet weak var label: UILabel!
	@IBOutlet weak var textField: UITextField!

}
