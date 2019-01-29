//
//  FilterListController.swift
//  CIFunHouseSwift
//
//  Created by Seyed Samad Gholamzadeh on 8/9/1396 AP.
//  Copyright © 1396 AP Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

protocol FilterListControllerDelegate: AnyObject {
	func filterListEditorDidDismiss()
}

class FilterListController: UITableViewController, AddFilterControllerDelegate, UIActionSheetDelegate, UIPopoverPresentationControllerDelegate {

	var addFilterButtonItem: UIBarButtonItem!
	var addFilterPopoverController: UIPopoverPresentationController!
	var addFilterNavigationController: UINavigationController!
	var delegate: FilterListControllerDelegate!
	
	var filterStack: FilterStack!
	var showDismissButton: Bool!
	var addButtonPaddingView: UIView!
	var screenSize: CGSize!
	
	//MARK: - View lifecycle
	
	@objc func dismissAction() {
		
		self.delegate.filterListEditorDidDismiss()

	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		
		self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

		let addFilterController = AddFilterController(style: UITableViewStyle.plain)
		addFilterController.filterStack = filterStack
		addFilterController.delegate = self
		addFilterController.preferredContentSize = CGSize(width: 320.0, height: 480.0)
		self.addFilterNavigationController = UINavigationController(rootViewController: addFilterController)
		
		self.addFilterButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(addAction(_:)))
		self.navigationItem.leftBarButtonItem = addFilterButtonItem

		if UIDevice.current.userInterfaceIdiom == .pad {
			//Fill Here in Future
			self.addFilterNavigationController.modalPresentationStyle = .popover
		}
		
		
		if UIDevice.current.userInterfaceIdiom == .phone {
			self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(dismissAction))
		}
		else {
			self.navigationItem.rightBarButtonItem = self.editButtonItem
		}
		
		self.title = "Filters"
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		if UIDevice.current.userInterfaceIdiom == .pad {
			self.navigationItem.rightBarButtonItem?.isEnabled = self.filterStack.activeFilters.count > 0
		}
		
	}
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return filterStack.activeFilters.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cellIdentifier = "cell"
		let cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
		
		// Configure the cell...
		let filter = self.filterStack.activeFilters[indexPath.row]
		if let displayName = filter.attributes[kCIAttributeFilterDisplayName] as? String {
			cell.textLabel?.text = displayName
		}
		cell.detailTextLabel?.text = filter.isSourceFilter ? nil : filter.name
		
		if filter.onlyRequiresInputImages {
			cell.accessoryType = UITableViewCellAccessoryType.none
		}
		else {
			cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
		}
		
		cell.selectionStyle = .blue
		cell.showsReorderControl = false
		
        return cell!
    }
	
	override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		// might be nice to have a yellow background color for the cell
		// if the item is not in use in the graph.
		// For example if the stack just contains two images.
		// The logic for this is a bit tricky though so it is left as an exercise.
		
		//    CIFilter *filter = [_filterStack.activeFilters objectAtIndex:indexPath.row];
		//    if (filter.isUnused)
		//        cell.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.75 alpha:1.0];
	}
	
	override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		// Only allow the last filter to be edited
		return indexPath.row == filterStack.activeFilters.count - 1
	}
	
	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
		if editingStyle == .delete {
			self.filterStack.removeLastFilter()  // only the last filter is deletable
			
			tableView.deleteRows(at: [indexPath], with: .fade)
			
			if self.isEditing && self.filterStack.activeFilters.count == 0 {
				self.isEditing = false
				self.editButtonItem.isEnabled = false
			}
		}
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let filter = self.filterStack.activeFilters[indexPath.row]
		
		if filter.onlyRequiresInputImages {
			self.tableView.deselectRow(at: indexPath, animated: true)
			return
		}
		
		let controller = FilterAttributesController(style: .grouped)
		controller.filter = filter
		controller.preferredContentSize = self.preferredContentSize
		controller.screenSize = self.screenSize
		self.navigationController?.pushViewController(controller, animated: true)
	}
	
	@objc func addAction(_ sender: UIBarButtonItem) {
				
		let controller = AddFilterController(style: .plain)
		controller.filterStack = self.filterStack
		controller.delegate = self
		controller.preferredContentSize = self.preferredContentSize
		
		if UIDevice.current.userInterfaceIdiom == .phone {
			self.present(self.addFilterNavigationController, animated: true, completion: nil)
		}
		else {
			self.addFilterPopoverController = self.addFilterNavigationController.popoverPresentationController!
			self.addFilterPopoverController.delegate = self
			self.addFilterPopoverController.barButtonItem = sender
			self.present(self.addFilterNavigationController, animated: true, completion: nil)
		}
	}
	
	//MARK: - AddFilterController delegate method
	func didAddFilter() {
		self.tableView.reloadData()

		if UIDevice.current.userInterfaceIdiom == .phone {
			self.addFilterNavigationController.dismiss(animated: true, completion: nil)
		}
		else {
			if self.addFilterNavigationController != nil {
				self.addFilterNavigationController.dismiss(animated: true, completion: nil)
				self.addFilterPopoverController = nil

			}
		}
	}
	
	func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
		self.didAddFilter()
	}
	
	
}
