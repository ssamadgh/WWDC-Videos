//
//  DetailViewController.swift
//  CoreDataBooks_Swift
//
//  Created by Seyed Samad Gholamzadeh on 2/3/19.
//  Copyright © 2019 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

class DetailViewController<Presenter: DetailVCPresenter>: UITableViewController {
	
	var presenter: Presenter!
	
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var authorLabel: UILabel!
	@IBOutlet weak var copyrightLabel: UILabel!
	
	override var undoManager: UndoManager? {
		return self.presenter.undoManager
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.tableView.allowsSelectionDuringEditing = true
		
		// if the local changes behind our back, we need to be notified so we can update the date
		// format in the table view cells
		//
		NotificationCenter.default.addObserver(self, selector: #selector(localeChanged(_:)), name: NSLocale.currentLocaleDidChangeNotification, object: nil)
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self, name: NSLocale.currentLocaleDidChangeNotification, object: nil)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		// Redisplay the data.
		self.updateInterface()
		self.updateRightBarButtonItemState()
	}
	
	override func setEditing(_ editing: Bool, animated: Bool) {
		super.setEditing(editing, animated: animated)
		
		// Hide the back button when editing starts, and show it again when editing finishes.
		self.navigationItem.setHidesBackButton(editing, animated: animated)
		
		self.presenter.prepareForEditing(editing)
	}
	
	func updateInterface() {
		self.presenter.bookInfo { (author, title, copyright) in
			self.authorLabel.text = author
			self.titleLabel.text = title
			self.copyrightLabel.text = copyright
		}
	}
	
	func updateRightBarButtonItemState() {
		// Conditionally enable the right bar button item -- it should only be enabled if the book is in a valid state for saving.
		self.navigationItem.rightBarButtonItem?.isEnabled = self.presenter.bookIsValidateForUpdate
	}
	
	// MARK: - TableViewDelegate
	
	override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
		// Only allow selection if editing.
		if self.isEditing {
			return indexPath
		}
		return nil
	}
	
	/*
	Manage row selection: If a row is selected, create a new editing view controller to edit the property associated with the selected row.
	*/
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if self.isEditing {
			self.performSegue(withIdentifier: "EditSelectedItem", sender: self)
		}
	}
	
	override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
		return .none
	}
	
	override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
		return false
	}
	
	/*
	The view controller must be first responder in order to be able to receive shake events for undo. It should resign first responder status when it disappears.
	*/
	override var canBecomeFirstResponder: Bool {
		return true
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		self.resignFirstResponder()
	}
	
	// MARK: - Segue management
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "EditSelectedItem" {
			let controller = segue.destination as! EditingViewController
			let indexPath = self.tableView.indexPathForSelectedRow!
			self.presenter.prepare(controller, for: indexPath)
			
		}
	}
	
	@objc func undoManagerDidUndo(_ notification: Notification) {
		// Redisplay the data.
		self.updateInterface()
		self.updateRightBarButtonItemState()
	}
	
	@objc func undoManagerDidRedo(_ notification: Notification) {
		// Redisplay the data.
		self.updateInterface()
		self.updateRightBarButtonItemState()
	}

	
	@objc func localeChanged(_ notif: NSNotification) {
		// the user changed the locale (region format) in Settings, so we are notified here to
		// update the date format in the table view cells
		//
		self.updateInterface()
	}
	
	
}
