//
//  PreviousRunPickerViewController.swift
//  Running with a Snap
//
//  Created by Seyed Samad Gholamzadeh on 7/11/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

class PreviousRunPickerViewController: UITableViewController {

	var runManager: RunManager!
	
	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		self.runManager = RunManager()
		let backBarButtonItem = UIBarButtonItem(title: "Run List", style: .plain, target: nil, action: nil)
		self.navigationItem.backBarButtonItem = backBarButtonItem
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.navigationItem.title = "\(self.runManager.numberOfRuns) runs"
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		if self.isBeingDismissed || self.isMovingFromParentViewController {
			self.navigationController?.setNavigationBarHidden(true, animated: false)
		}
	}
	
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.runManager.numberOfRuns
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
        // Configure the cell...
		let run = self.runManager.run(at: indexPath.row)
		cell.textLabel?.text = run.whereIs
		cell.detailTextLabel?.text = DateFormatter.localizedString(from: run.whenIs, dateStyle: .short, timeStyle: .short)
		
        return cell
    }

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let vc = PreviousRunEditorMenuViewController(nibName: nil, bundle: nil)
		vc.run = self.runManager.run(at: indexPath.row)
		self.navigationController?.show(vc, sender: nil)
		self.tableView.deselectRow(at: indexPath, animated: true)
	}
}
