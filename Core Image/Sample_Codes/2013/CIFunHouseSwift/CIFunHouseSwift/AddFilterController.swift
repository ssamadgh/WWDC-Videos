//
//  AddFilterController.swift
//  CIFunHouseSwift
//
//  Created by Seyed Samad Gholamzadeh on 8/9/1396 AP.
//  Copyright © 1396 AP Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit
import Photos
import MobileCoreServices

enum FilterControllerType {
	case general, generator
}

protocol AddFilterControllerDelegate: AnyObject {
	func didAddFilter()
}

class AddFilterController: UITableViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIPopoverPresentationControllerDelegate {

	var delegate: AddFilterControllerDelegate!
	var filterStack = FilterStack()
	var controllerType: FilterControllerType!
	
	var imagePickerPopoverController: UIPopoverPresentationController!
	var imagePickerNavigationController: UINavigationController!
	
	var filters: [FilterDescriptor] {
		return filterStack.possibleNextFilters
	}
	
	
	enum AddFilterTableSection: Int {
		case sourceType, filterType
	}
	
	//MARK: - View lifecycle
	
    override func viewDidLoad() {
        super.viewDidLoad()
		self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

		self.title = "Add Filter"
		NotificationCenter.default.addObserver(self, selector: #selector(handleFilterStackActiveFilterListDidChangeNotification(_:)), name: NSNotification.Name(FilterStackActiveFilterListDidChangeNotification), object: nil)
    }
	
	@objc func handleFilterStackActiveFilterListDidChangeNotification(_ notification: Notification) {
		self.tableView.reloadData()
	}
	
	
//	func shouldAutorotateToInterfaceOrientation(_ interfaceOrienation: UIInterfaceOrientation) -> Bool {
//		if UIDevice.current.userInterfaceIdiom == .phone {
//			return interfaceOrientation != .portraitUpsideDown
//		}
//		else {
//			return true
//		}
//	}

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		if section == AddFilterTableSection.sourceType.rawValue {
			return "Sources"
		}
		else {
			return "Filters"
		}
	}

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
		return section == AddFilterTableSection.sourceType.rawValue ? filterStack.sources.count : filterStack.possibleNextFilters.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cellIdentifier = "cell"
		var cell: UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        // Configure the cell...
		if cell == nil {
			cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: cellIdentifier)
		}
		
		let data = indexPath.section == AddFilterTableSection.sourceType.rawValue ? filterStack.sources : filterStack.possibleNextFilters
		let descriptor = data[indexPath.row]
		cell?.textLabel?.text = descriptor.displayName
		
		if descriptor.filter! is SourceFilter {
			cell?.detailTextLabel?.text = nil
		}
		else {
			cell?.detailTextLabel?.text = descriptor.name
		}

        return cell!
    }
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let data = indexPath.section == AddFilterTableSection.sourceType.rawValue ? filterStack.sources : filterStack.possibleNextFilters
		let descriptor = data[indexPath.row]
		if let filter = descriptor.filter {
			if filter is SourcePhotoFilter {
				
				if self.imagePickerNavigationController == nil {
					self.imagePickerNavigationController = UIImagePickerController()
					self.imagePickerNavigationController.delegate = self
				}
				
				if UIDevice.current.userInterfaceIdiom == .pad {
					
					if self.imagePickerPopoverController == nil {
						
//						let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//						let vc = storyboard.instantiateViewControllerWithIdentifier("PopoverViewController") as! UIViewController
//						vc.modalPresentationStyle = UIModalPresentationStyle.Popover
//						let popover: UIPopoverPresentationController = vc.popoverPresentationController!
//						presentViewController(vc, animated: true, completion:nil)
						
						self.imagePickerNavigationController.modalPresentationStyle = .popover
						self.imagePickerPopoverController = self.imagePickerNavigationController.popoverPresentationController!
						self.imagePickerPopoverController.delegate = self
						self.imagePickerPopoverController.sourceView = self.view
						self.imagePickerPopoverController.sourceRect = self.navigationController!.view.bounds
						self.navigationController?.present(self.imagePickerNavigationController, animated: true, completion: nil)

					}
				}
				else {
					self.navigationController?.present(self.imagePickerNavigationController, animated: true, completion: nil)
				}
				return
			}
			
			self.filterStack.append(filter)
			self.delegate.didAddFilter()
			self.tableView.reloadData()
			
		}
	}
	
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
		let mediaType = info[UIImagePickerControllerMediaType] as! NSString
		if mediaType.isEqual(to: kUTTypeImage as String) {
			// Media is an image
			let url = info[UIImagePickerControllerImageURL] as! URL
			let ciImage = CIImage(contentsOf: url)

			if let filter = CIFilter(name: "SourcePhotoFilter") {

				filter.setValue(ciImage, forKey: kCIInputImageKey)
				
				self.filterStack.append(filter)
				self.tableView.reloadData()
			}
			
			if self.imagePickerNavigationController != nil {
				self.imagePickerNavigationController.dismiss(animated: true, completion: nil)
				self.imagePickerPopoverController = nil
				self.imagePickerNavigationController = nil
			}
			else {
				self.navigationController?.dismiss(animated: true, completion: nil)
			}
			self.delegate.didAddFilter()

		}
	}
	
	func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		
		self.imagePickerDismissed()
	}
	
	func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
		if popoverPresentationController == self.imagePickerPopoverController {
			self.imagePickerDismissed()
		}
	}
	
	func imagePickerDismissed() {
		if self.imagePickerNavigationController != nil {
			self.imagePickerNavigationController.dismiss(animated: true, completion: nil)
			self.imagePickerPopoverController = nil
			self.imagePickerNavigationController = nil
		}
		else {
			self.navigationController?.dismiss(animated: true, completion: nil)
		}
		
		if let indexPath = self.tableView.indexPathForSelectedRow {
			self.tableView.deselectRow(at: indexPath, animated: true)
		}
	}
}
