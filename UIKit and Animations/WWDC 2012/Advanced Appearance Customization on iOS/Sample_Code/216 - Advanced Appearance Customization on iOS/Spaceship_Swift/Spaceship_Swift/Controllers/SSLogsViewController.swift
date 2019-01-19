//
//  SSLogsViewController.swift
//  Spaceship_Swift
//
//  Created by Seyed Samad Gholamzadeh on 6/20/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

class SSLogsViewController: UITableViewController {
	
	var spaceship: SSSpaceship!
	
	@IBOutlet weak var leftItem: UIBarButtonItem!
	@IBOutlet weak var rightItem: UIBarButtonItem!
	@IBOutlet weak var deleteItem: UIBarButtonItem!

	var currentLog: SSLog? {
		if let controller = self.navigationController?.topViewController as? SSLogViewController {
			return controller.log
		}
		else {
			return nil
		}
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.setLogItemsEnabled(false)
	}
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		self.setLogItemsEnabled(true)
		
	}

	func setLogItemsEnabled(_ isEnabled: Bool) {
		
		self.leftItem.isEnabled = isEnabled && self.canChangeLog(self.leftItem)
		self.rightItem.isEnabled = isEnabled && self.canChangeLog(self.rightItem)
		self.deleteItem.isEnabled = isEnabled
		
	}
	
	//MARK: - Actions
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		
		if segue.identifier == "showLog" {
			guard let tableView = self.tableView.visibleCells.contains(sender as! UITableViewCell) ? self.tableView : self.searchDisplayController?.searchResultsTableView
				
				, let indexPath = tableView.indexPath(for: sender as! UITableViewCell)
				else { return }
			
			let logs = self.logs(for: tableView)
			
			let row = indexPath.row
			
			let log = logs[row]
			
			let controller = segue.destination as! SSLogViewController
			controller.log = log
			controller.toolbarItems = self.toolbarItems
		}
		
	}
	
	@IBAction func done(_ sender: UIBarButtonItem) {
		self.presentingViewController?.dismiss(animated: true, completion: nil)
	}
	
	@IBAction func addLog(_ sender: UIBarButtonItem) {
		
		let newLog = SSLog()
		var logs = self.spaceship.logs
		logs.append(newLog)
		self.spaceship.logs = logs
		let indexPath = IndexPath(row: logs.count - 1, section: 0)
		self.tableView.insertRows(at: [indexPath], with: .automatic)
		self.tableView.selectRow(at: indexPath, animated: false, scrollPosition: .bottom)
		let controller = self.navigationController?.topViewController
		if controller == self {
			let cell = self.tableView.cellForRow(at: indexPath)
			self.performSegue(withIdentifier: "showLog", sender: cell)
		}
		else {
			(controller as! SSLogViewController).log = newLog
			self.setLogItemsEnabled(true)
		}
	}
	
	@IBAction func deleteLog( _ sender: UIBarButtonItem) {
		
		guard let currentLog = self.currentLog else { return }
		var logs = self.spaceship.logs
		let currentLogIndex = logs.index(of: currentLog)!
		let indexPath = IndexPath(row: currentLogIndex, section: 0)
		
		logs.remove(at: currentLogIndex)
		self.spaceship.logs = logs
		self.tableView.deleteRows(at: [indexPath], with: .automatic)
		self.navigationController?.popViewController(animated: true)
	}
	
	func canChangeLog(_ sender: UIBarButtonItem) -> Bool {
		
		guard let currentLog = self.currentLog else { return false }
		var index = Int(self.spaceship.logs.index(of: currentLog)!)
		index += sender.tag
		return index >= 0 && index < self.spaceship.logs.count
	}
	
	@IBAction func changeLog( _ sender: UIBarButtonItem) {
		
		if self.canChangeLog(sender) {
			guard let currentLog = self.currentLog else { return }
			var index = Int(self.spaceship.logs.index(of: currentLog)!)
			index += sender.tag
			let newLog = self.spaceship.logs[index]
			
			if let controller = self.navigationController?.topViewController as? SSLogViewController {
				controller.log = newLog
				self.setLogItemsEnabled(true)
				let indexPath = IndexPath(row: index, section: 0)
				self.tableView.selectRow(at: indexPath, animated: false, scrollPosition: .middle)
			}
		}

	}
	
	
	// MARK: - Table view data source
	
	func logs(for tableView: UITableView) -> Array<SSLog> {
		
		var logs = self.spaceship.logs
		
		if tableView != self.tableView {
			guard
			let searchBar = self.searchDisplayController?.searchBar,
			let searchString = searchBar.text
			else { return logs }
			
			let selectedScope = searchBar.selectedScopeButtonIndex

			if selectedScope == 0 {
				logs = logs.filter { $0.attributedText.string.contains(searchString) }
			}
			else if selectedScope == 1 {
				logs = logs.filter { $0.dateDescription!.contains(searchString) }
			}
			else {
				logs = logs.filter { $0.dateDescription!.contains(searchString) || $0.attributedText.string.contains(searchString) }
			}
		}
		
		return logs
		
	}
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		// #warning Incomplete implementation, return the number of sections
		return 1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		// #warning Incomplete implementation, return the number of rows
		return self.logs(for: tableView).count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "LogCell", for: indexPath)
		
		// Configure the cell...
		let logs = self.logs(for: tableView)
		let row = indexPath.row
		let log = logs[row]
		cell.textLabel?.text = log.dateDescription
		return cell
	}
	
}
