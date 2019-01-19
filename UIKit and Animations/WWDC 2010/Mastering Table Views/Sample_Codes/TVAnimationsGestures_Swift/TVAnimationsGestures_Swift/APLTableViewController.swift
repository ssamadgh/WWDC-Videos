//
//  APLTableViewController.swift
//  TVAnimationsGestures_Swift
//
//  Created by Seyed Samad Gholamzadeh on 6/22/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit
import MessageUI

class APLEmailMenuItem: UIMenuItem {
	
	var indexPath: IndexPath?
}

class APLTableViewController: UITableViewController, MFMailComposeViewControllerDelegate, SectionHeaderViewDelegate {

	let QuoteCellIdentifier = "QuoteCellIdentifier"
	let SectionHeaderViewIdentifier = "SectionHeaderViewIdentifier"
	let DEFAULT_ROW_HEIGHT: CGFloat = 88
	let HEADER_HEIGHT: CGFloat = 48

	
	var plays: Array<APLPlay> = []
	
	var sectionInfoArray: [APLSectionInfo]!
	var pinchedIndexPath: IndexPath!
	var openSectionIndex: Int!
	var initialPinchHeight: CGFloat!
	
	@IBOutlet weak var sectionHeaderView: APLSectionHeaderView!
	
	// use the uniformRowHeight property if the pinch gesture should change all row heights simultaneously
	var uniformRowHeight: CGFloat!
	
    override func viewDidLoad() {
        super.viewDidLoad()

		// Add a pinch gesture recognizer to the table view.
		let pinchRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
		self.tableView.addGestureRecognizer(pinchRecognizer)
		
		// Set up default values.
		self.tableView.sectionHeaderHeight = HEADER_HEIGHT;
		
		/*
		The section info array is thrown away in viewWillUnload, so it's OK to set the default values here. If you keep the section information etc. then set the default values in the designated initializer.
		*/
		self.uniformRowHeight = DEFAULT_ROW_HEIGHT;
		self.openSectionIndex = NSNotFound;
		
		let sectionHeaderNib = UINib(nibName: "SectionHeaderView", bundle: nil)
		self.tableView.register(sectionHeaderNib, forHeaderFooterViewReuseIdentifier: SectionHeaderViewIdentifier)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		/*
		Check whether the section info array has been created, and if so whether the section count still matches the current section count. In general, you need to keep the section info synchronized with the rows and section. If you support editing in the table view, you need to appropriately update the section info during editing operations.
		*/
		if self.sectionInfoArray == nil || self.sectionInfoArray.count != self.numberOfSections(in: self.tableView) {
			
			// For each play, set up a corresponding SectionInfo object to contain the default height for each row.
			var infoArray: [APLSectionInfo] = []
			
			for play in self.plays {
				
				let sectionInfo = APLSectionInfo()
				sectionInfo.play = play
				sectionInfo.isOpen = false
				
				let defaultRowHeight = DEFAULT_ROW_HEIGHT
				
				let countOfQuotations = sectionInfo.play.quotations.count
				
				for i in 0..<countOfQuotations {
					sectionInfo.insert(defaultRowHeight, inRowHeightsAt: i)
				}
				
				infoArray.append(sectionInfo)
			}
			
			self.sectionInfoArray = infoArray
		}
		
	}


    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return self.plays.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
		let sectionInfo = self.sectionInfoArray[section]
		let numStoriesInSection = sectionInfo.play.quotations.count

        return sectionInfo.isOpen ? numStoriesInSection : 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: QuoteCellIdentifier, for: indexPath) as! APLQuoteCell

        // Configure the cell...
		if MFMailComposeViewController.canSendMail() {
			if cell.longPressRecognizer == nil {
				let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
				cell.longPressRecognizer = longPressRecognizer
			}
		}
		else {
			cell.longPressRecognizer = nil
		}

		let play = self.sectionInfoArray[indexPath.section].play
		cell.quoatation = play!.quotations[indexPath.row]
        return cell
    }

	override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		
		let sectionHeaderView = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: SectionHeaderViewIdentifier) as! APLSectionHeaderView
		let sectionInfo = self.sectionInfoArray[section]
		sectionInfo.headerView = sectionHeaderView
		
		sectionHeaderView.titleLabel.text = sectionInfo.play.name
		sectionHeaderView.section = section
		sectionHeaderView.delegate = self
		
		return sectionHeaderView;

	}
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		let sectionInfo = self.sectionInfoArray[indexPath.section]
		return sectionInfo.objectInRowHeightsAtIndex(indexPath.row)
		// Alternatively, return rowHeight.
	}
	
	//MARK: - SectionHeaderViewDelegate
	func sectionHeaderView(_ sectionHeaderView: APLSectionHeaderView, sectionOpened section: Int) {
		
		let sectionInfo = self.sectionInfoArray[section]
		sectionInfo.isOpen = true
		
		/*
		Create an array containing the index paths of the rows to insert: These correspond to the rows for each quotation in the current section.
		*/
		let countOfRowsToInsert = sectionInfo.play.quotations.count
		var indexPathsToInsert: [IndexPath] = []
		
		for i in 0..<countOfRowsToInsert {
			indexPathsToInsert.append(IndexPath(row: i, section: section))
		}
		
		/*
		Create an array containing the index paths of the rows to delete: These correspond to the rows for each quotation in the previously-open section, if there was one.
		*/
		var indexPathsToDelete: [IndexPath] = []
		
		let previousOpenSectionIndex = self.openSectionIndex!
		
		if previousOpenSectionIndex != NSNotFound {
			
			let previousOpenSection = self.sectionInfoArray[previousOpenSectionIndex]
			previousOpenSection.isOpen = false
			previousOpenSection.headerView.toggleOpenWithUserAction(false)
			let countOfRowsToDelete = previousOpenSection.play.quotations.count
			for i in 0..<countOfRowsToDelete {
				indexPathsToDelete.append(IndexPath(row: i, section: previousOpenSectionIndex))
			}
		}
		
		// style the animation so that there's a smooth flow in either direction
		let insertAnimation: UITableViewRowAnimation
		let deleteAnimation: UITableViewRowAnimation
		if (previousOpenSectionIndex == NSNotFound || section < previousOpenSectionIndex) {
			insertAnimation = .top
			deleteAnimation = .bottom
		}
		else {
			insertAnimation = .bottom
			deleteAnimation = .top
		}
		
		// apply the updates
		self.tableView.beginUpdates()
		self.tableView.insertRows(at: indexPathsToInsert, with: insertAnimation)
		self.tableView.deleteRows(at: indexPathsToDelete, with: deleteAnimation)
		self.tableView.endUpdates()
		
		self.openSectionIndex = section
	}
	
	func sectionHeaderView(_ sectionHeaderView: APLSectionHeaderView, sectionClosed section: Int) {
		
		/*
		Create an array of the index paths of the rows in the section that was closed, then delete those rows from the table view.
		*/
		let sectionInfo = self.sectionInfoArray[section]
		sectionInfo.isOpen = false
		let countOfRowsToDelete = self.tableView.numberOfRows(inSection: section)
		
		if countOfRowsToDelete > 0 {
			var indexPathsToDelete: [IndexPath] = []
			for i in 0..<countOfRowsToDelete {
				indexPathsToDelete.append(IndexPath(row: i, section: section))
			}
			self.tableView.deleteRows(at: indexPathsToDelete, with: .top)
		}
		self.openSectionIndex = NSNotFound
	}
	
	//MARk: - Handling pinches
	
	@objc func handlePinch( _ pinchRecognizer: UIPinchGestureRecognizer) {
		
		/*
		There are different actions to take for the different states of the gesture recognizer.
		* In the Began state, use the pinch location to find the index path of the row with which the pinch is associated, and keep a reference to that in pinchedIndexPath. Then get the current height of that row, and store as the initial pinch height. Finally, update the scale for the pinched row.
		* In the Changed state, update the scale for the pinched row (identified by pinchedIndexPath).
		* In the Ended or Canceled state, set the pinchedIndexPath property to nil.
		*/
		
		if pinchRecognizer.state == .began {
			let pinchLocation = pinchRecognizer.location(in: self.tableView)
			let newPinchedIndexPath = self.tableView.indexPathForRow(at: pinchLocation)!
			self.pinchedIndexPath = newPinchedIndexPath
			
			let sectionInfo = self.sectionInfoArray[newPinchedIndexPath.section]
			self.initialPinchHeight = sectionInfo.objectInRowHeightsAtIndex(newPinchedIndexPath.row)
			
			// Alternatively, set initialPinchHeight = uniformRowHeight.
			
			self.updateForPinchScale(pinchRecognizer.scale, atIndexPath: newPinchedIndexPath)
		}
		else {
			if pinchRecognizer.state == .changed {
				self.updateForPinchScale(pinchRecognizer.scale, atIndexPath: self.pinchedIndexPath)
			}
			else if pinchRecognizer.state == .cancelled || pinchRecognizer.state == .ended {
				self.pinchedIndexPath = nil
			}
		}
	}
	
	func updateForPinchScale( _ scale: CGFloat, atIndexPath indexPath: IndexPath?) {
		
		if indexPath != nil && (indexPath?.section != NSNotFound) && (indexPath?.row != NSNotFound) {
			let newHeight = round(max(self.initialPinchHeight*scale, DEFAULT_ROW_HEIGHT))
			
			let sectionInfo = self.sectionInfoArray[indexPath!.section]
			sectionInfo.replaceObjectInRowHeightsAt(indexPath!.row, with: newHeight)
			// Alternatively, set uniformRowHeight = newHeight.
			
			/*
			Switch off animations during the row height resize, otherwise there is a lag before the user's action is seen.
			*/
			let areAnimationsEnabled = UIView.areAnimationsEnabled
			UIView.setAnimationsEnabled(false)
			self.tableView.beginUpdates()
			self.tableView.endUpdates()
			UIView.setAnimationsEnabled(areAnimationsEnabled)
		}
	}
	
	
	//MARK: - Handling long presses
	
	@objc func handleLongPress(_ longPressRecognizer: UILongPressGestureRecognizer) {
		
		/*
		For the long press, the only state of interest is Began.
		When the long press is detected, find the index path of the row (if there is one) at press location.
		If there is a row at the location, create a suitable menu controller and display it.
		*/
		if longPressRecognizer.state == .began {
			
			let pressedIndexPath = self.tableView.indexPathForRow(at: longPressRecognizer.location(in: self.tableView))
			if pressedIndexPath != nil && (pressedIndexPath!.row != NSNotFound) && (pressedIndexPath?.section != NSNotFound) {
				
				self.becomeFirstResponder()
				let title = NSLocalizedString("Email", comment: "Email menu title")
				let menuItem = APLEmailMenuItem(title: title, action: #selector(emailMenuButtonPressed(_:)))
				menuItem.indexPath = pressedIndexPath
				
				let menuController = UIMenuController.shared
				menuController.menuItems = [menuItem]
				
				var cellRect = self.tableView.rectForRow(at: pressedIndexPath!)
				// lower the target rect a bit (so not to show too far above the cell's bounds)
				cellRect.origin.y += 40.0
				menuController.setTargetRect(cellRect, in: self.tableView)
				menuController.setMenuVisible(true, animated: true)
			}
		}
	}
	
	@objc func emailMenuButtonPressed(_ menuController: UIMenuController) {
		
		let menuItem = UIMenuController.shared.menuItems?[0] as! APLEmailMenuItem
		if let indexPath = menuItem.indexPath {
			self.resignFirstResponder()
			self.sendEmailForEntryAtIndexPath(indexPath)
		}
	}
	
	func sendEmailForEntryAtIndexPath(_ indexPath: IndexPath) {
		let play = self.plays[indexPath.section]
		let quotation = play.quotations[indexPath.row]
		
		// In production, send the appropriate message.
		print("Send email using quotation: \(quotation.quotation)");
	}
	
	func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
		self.dismiss(animated: true, completion: nil)
		if result == MFMailComposeResult.failed {
			// In production, display an appropriate message to the user.
			print("Mail send failed with error: \(error?.localizedDescription)")
		}
	}

}
