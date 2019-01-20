//
//  TTTHistoryListTableViewController.swift
//  TicTacToeApp_Swift
//
//  Created by Seyed Samad Gholamzadeh on 7/12/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

class TTTHistoryListTableViewController: UITableViewController {

	var profile: TTTProfile!
	
	let CellIdentifier = "Cell"
	
	init() {
		super.init(style: .plain)
		
		self.title = NSLocalizedString("History", comment: "History")

	}
	
	override convenience init(style: UITableViewStyle) {
		self.init()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func loadView() {
		super.loadView()
		
		self.tableView.register(TTTHistoryListTableViewCell.self, forCellReuseIdentifier: CellIdentifier)
	}
	
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.profile.games.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier, for: indexPath)

        // Configure the cell...

        return cell
    }
	
	override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		
		let game = self.profile.games[indexPath.row]
		cell.textLabel?.text = DateFormatter.localizedString(from: game.date, dateStyle: .short, timeStyle: .short)
		
		let result = game.result
		
		if result == .victory {
			cell.detailTextLabel?.text = NSLocalizedString("Victory", comment: "Victory")
		}
		else if result == .defeat {
			cell.detailTextLabel?.text = NSLocalizedString("Defeat", comment: "Defeat")
		}
		else if result == .draw {
			cell.detailTextLabel?.text = NSLocalizedString("Draw", comment: "Draw")
		}
		else {
			cell.detailTextLabel?.text = nil
		}
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let controller = TTTGameHistoryViewController()
		controller.profile = self.profile
		controller.game = self.profile.games[indexPath.row]
		self.navigationController?.show(controller, sender: self)
	}
}

class TTTHistoryListTableViewCell: UITableViewCell {
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
		self.accessoryType = .disclosureIndicator
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func tintColorDidChange() {
		super.tintColorDidChange()
		self.detailTextLabel?.textColor = self.tintColor
	}
}


