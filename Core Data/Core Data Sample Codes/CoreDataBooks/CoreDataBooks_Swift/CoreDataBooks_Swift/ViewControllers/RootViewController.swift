//
//  RootViewController.swift
//  CoreDataBooks_Swift
//
//  Created by Seyed Samad Gholamzadeh on 2/3/19.
//  Copyright © 2019 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit
import CoreData

class RootViewController: UITableViewController {

	var presenter: RootVCPresenter!

	var rightBarButtonItem: UIBarButtonItem!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		self.navigationItem.leftBarButtonItem = self.editButtonItem;

		self.presenter.fetchInitialEntities(withSectionKey: "author", for: self) { (isEmpty) in
			self.tableView.reloadData()
		}
    }
	
	// MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return self.presenter.numberOfSections
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.presenter.numberOfEntities(at: section)
    }

	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return self.presenter[section]?.name
	}
	
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        // Configure the cell...
		self.configure(cell, at: indexPath)
        return cell
    }

	
	func configure(_ cell: UITableViewCell, at indexPath: IndexPath) {
		// Configure the cell to show the book's title
		let book = self.presenter[indexPath]
		cell.textLabel?.text = book?.title
	}
	
	override func update(_ cell: UITableViewCell, at indexPath: IndexPath) {
		self.configure(cell, at: indexPath)
	}
	
	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
		if editingStyle == .delete {
			// Delete the managed object.
			self.presenter.deleteObject(at: indexPath)
		}
	}
	
	override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
		return false
	}
	
	@IBAction func itemAction(_ sender: UIBarButtonItem) {
		let indexPath = IndexPath(row: 0, section: 0)
		let object = self.presenter[indexPath]
		object?.title = "\(Int.random(in: 0...1000))"
	}
	
	
	override func setEditing(_ editing: Bool, animated: Bool) {
		super.setEditing(editing, animated: animated)
		
		if editing {
			self.rightBarButtonItem = self.navigationItem.rightBarButtonItem
			self.navigationItem.rightBarButtonItem = nil
		}
		else {
			self.navigationItem.rightBarButtonItem = self.rightBarButtonItem
			self.rightBarButtonItem = nil
		}
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		
		if segue.identifier == "AddBook" {
			let navController = segue.destination as! UINavigationController
			let addViewController = navController.topViewController as! AddViewController
			self.presenter.prepare(addViewController)
		}
		else if segue.identifier == "ShowSelectedBook" {
			let showViewController = segue.destination as! ShowViewController
			let indexPath = self.tableView.indexPathForSelectedRow!
			self.presenter.prepare(showViewController, for: indexPath)

		}
		
	}
	
}
