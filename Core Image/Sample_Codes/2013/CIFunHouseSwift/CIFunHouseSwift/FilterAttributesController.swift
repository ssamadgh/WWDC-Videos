//
//  FilterAttributesController.swift
//  CIFunHouseSwift
//
//  Created by Seyed Samad Gholamzadeh on 8/9/1396 AP.
//  Copyright © 1396 AP Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

class FilterAttributesController: UITableViewController, UIActionSheetDelegate {

	var filter: CIFilter!
	var screenSize: CGSize!
	var attributeBindings: [FilterAttributeBinding]!
	
	override var shouldAutorotate: Bool {
		return true
	}
	
	//MARK: - View lifecycle
	
	@objc func resetAction() {
		for binding in self.attributeBindings {
			binding.revertToDefaultValues()
		}
		self.tableView.reloadData()
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

		// create the attribute bindings
		self.attributeBindings = []
		
		for key in self.filter.inputKeys {
			if let attrDict = self.filter.attributes[key] as? [String : Any] {
				if CIFilter.isAttributeConfigurable(filterAttributeDictionary: attrDict) {
					let binding = FilterAttributeBinding(filter: self.filter, name: key, dictionary: attrDict, screenSize: self.screenSize)
					self.attributeBindings.append(binding)
				}
			}
		}
		
		self.title = self.filter.attributes[kCIAttributeFilterDisplayName] as? String ?? filter.name
		self.tableView.rowHeight = SliderCell.cellHeight
		self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Reset", style: .plain, target: self, action: #selector(resetAction))
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.tableView.reloadData()
	}
	
	
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return self.attributeBindings.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
		if section >= self.attributeBindings.count {
			return 0
		}
		
		let binding = self.attributeBindings[section]
		return binding.elementCount
    }
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		if section >= self.attributeBindings.count {
			return nil
		}
		let binding = self.attributeBindings[section]
		return binding.elementCount > 1 ? binding.title : nil
	}

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cellIdentifier = "cell"
		var cell: SliderCell! = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? SliderCell
		// Configure the cell...
		if cell == nil {
			cell = SliderCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: cellIdentifier)
		}
		else {
			(cell.delegate as! FilterAttributeBinding).unbind(cell: cell)
		}
		
		let binding = self.attributeBindings[indexPath.section]
		let index = indexPath.row
		binding.bind(cell, toIndex: index)
		cell.selectionStyle = .none
		cell.delegate = binding
		cell.titleLabel.text = binding.elementCount > 1 ? binding.titleFor(index: index) : binding.title
		cell.slider.minimumValue = Float(binding.minElementValue)
		cell.slider.maximumValue = Float(binding.maxElementValue)
		cell.slider.value = Float(binding.elementValue(for: index))
		cell.slider.sendActions(for: .valueChanged)

        return cell
    }
	
	override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
		
		// disallow selection of any cell
		return nil
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		// disallow selection of any cell
		return
	}

}
