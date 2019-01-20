//
//  TTTProfileViewController.swift
//  TicTacToeApp_Swift
//
//  Created by Seyed Samad Gholamzadeh on 7/12/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

enum TTTProfileViewControllerSection: Int {
	case icon, statistics, history, count
}

class TTTProfileViewController: UITableViewController {
	
	var profile: TTTProfile!
	var profileURL: URL!
	
	let IconIdentifier = "Icon"
	let StatisticsIdentifier = "Statistics"
	let HistoryIdentifier = "History"

	static func viewController(with profile: TTTProfile, profileURL: URL) -> UIViewController {
		
		let controller: TTTProfileViewController = TTTProfileViewController()
		controller.profile = profile
		controller.profileURL = profileURL
		let navController = UINavigationController(rootViewController: controller)
		return navController
	}
	
	init() {
		super.init(style: .grouped)
		
		self.title = NSLocalizedString("Profile", comment: "Profile")
		self.tabBarItem.image = UIImage(named: "profileTab")
		self.tabBarItem.selectedImage = UIImage(named: "profileTabSelected")
	}
	
	override convenience init(style: UITableViewStyle) {
		self.init()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func loadView() {
		super.loadView()
		self.tableView.register(TTTProfileIconTableViewCell.self, forCellReuseIdentifier: IconIdentifier)
		self.tableView.register(TTTProfileStatisticsTableViewCell.self, forCellReuseIdentifier: StatisticsIdentifier)
		self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: HistoryIdentifier)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		let rowCount = self.tableView.numberOfRows(inSection: TTTProfileViewControllerSection.statistics.rawValue)
		var indexPaths: [IndexPath] = []
		for row in 0..<rowCount {
			indexPaths.append(IndexPath(row: row, section: TTTProfileViewControllerSection.statistics.rawValue))
		}
		self.tableView.reloadRows(at: indexPaths, with: .none)
	}
	
	@objc func changeIcon(_ sender: UISegmentedControl) {
		self.profile.icon = TTTProfileIcon(rawValue: sender.selectedSegmentIndex)
	}
	
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return TTTProfileViewControllerSection.count.rawValue
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		switch section {
		case TTTProfileViewControllerSection.icon.rawValue:
			return 1
		case TTTProfileViewControllerSection.statistics.rawValue:
			return 3
		case TTTProfileViewControllerSection.history.rawValue:
			return 1

		default:
			return 0
		}
	}

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        // Configure the cell...
		switch indexPath.section {
		case TTTProfileViewControllerSection.icon.rawValue:
			return tableView.dequeueReusableCell(withIdentifier: IconIdentifier, for: indexPath)
		case TTTProfileViewControllerSection.statistics.rawValue:
			return tableView.dequeueReusableCell(withIdentifier: StatisticsIdentifier, for: indexPath)
		case TTTProfileViewControllerSection.history.rawValue:
			return tableView.dequeueReusableCell(withIdentifier: HistoryIdentifier, for: indexPath)

		default:
			return tableView.dequeueReusableCell(withIdentifier: IconIdentifier, for: indexPath)
		}

    }

	override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		
		let section = indexPath.section
		let row = indexPath.row
		
		switch section {
		case TTTProfileViewControllerSection.icon.rawValue:
			cell.selectionStyle = .none
			(cell as! TTTProfileIconTableViewCell).segmentedControl.selectedSegmentIndex = self.profile.icon.rawValue
			(cell as! TTTProfileIconTableViewCell).segmentedControl.addTarget(self, action: #selector(changeIcon(_:)), for: .valueChanged)
			
		case TTTProfileViewControllerSection.statistics.rawValue:
			cell.selectionStyle = .none
			if row == 0 {
				cell.textLabel?.text = NSLocalizedString("Victories", comment: "Victories")
				cell.imageView?.image = UIImage(named: "victory")?.withRenderingMode(.alwaysTemplate)
				(cell as! TTTProfileStatisticsTableViewCell).countView.count = self.profile.numberOfGames(with: .victory)
			}
			else if row == 1 {
				cell.textLabel?.text = NSLocalizedString("Defeats", comment: "Defeats")
				cell.imageView?.image = UIImage(named: "defeat")?.withRenderingMode(.alwaysTemplate)
				(cell as! TTTProfileStatisticsTableViewCell).countView.count = self.profile.numberOfGames(with: .defeat)
			}
			else if row == 2 {
				cell.textLabel?.text = NSLocalizedString("Draws", comment: "Draws")
				cell.imageView?.image = UIImage(named: "draw")?.withRenderingMode(.alwaysTemplate)
				(cell as! TTTProfileStatisticsTableViewCell).countView.count = self.profile.numberOfGames(with: .draw)
			}
		case TTTProfileViewControllerSection.history.rawValue:
			cell.textLabel?.text = NSLocalizedString("Show History", comment: "Show History")
			cell.textLabel?.textAlignment = .center
			
		default: break
			
		}
	}
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		if section == TTTProfileViewControllerSection.statistics.rawValue {
			return NSLocalizedString("Statistics", comment: "Statistics")
		}
		
		return nil
	}
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if indexPath.section == TTTProfileViewControllerSection.icon.rawValue {
			return 100.0
		}
		
		return tableView.rowHeight
	}
	override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
		if indexPath.section == TTTProfileViewControllerSection.history.rawValue {
			return indexPath
		}
		
		return nil
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let controller = TTTHistoryListTableViewController()
		controller.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(closeHistory(_:)))
		controller.profile = self.profile
		
		let navController = UINavigationController(rootViewController: controller)
		navController.navigationBar.backIndicatorImage = UIImage(named: "backIndicator")
		navController.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "backIndicatorMask")
		
		self.present(navController, animated: true, completion: nil)
	}
	
	@objc func closeHistory(_ sender: Any) {
		self.dismiss(animated: true, completion: nil)
	}

}

class TTTProfileIconTableViewCell: UITableViewCell {
	
	var segmentedControl: UISegmentedControl!
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		
		let x = TTTProfile.image(for: .X).withRenderingMode(.alwaysOriginal)
		let o = TTTProfile.image(for: .O).withRenderingMode(.alwaysOriginal)
		
		self.segmentedControl = UISegmentedControl(items: [x, o])
		self.segmentedControl.frame = CGRect(x: 0.0, y: 0.0, width: 240.0, height: 80.0)
		let capInsets = UIEdgeInsets(top: 6.0, left: 6.0, bottom: 6.0, right: 6.0)
		self.segmentedControl.setBackgroundImage(UIImage(named: "segmentBackground")?.resizableImage(withCapInsets: capInsets), for: .normal, barMetrics: .default)
		self.segmentedControl.setBackgroundImage(UIImage(named: "segmentBackgroundHighlighted")?.resizableImage(withCapInsets: capInsets), for: .highlighted, barMetrics: .default)
		self.segmentedControl.setBackgroundImage(UIImage(named: "segmentBackgroundSelected")?.resizableImage(withCapInsets: capInsets), for: .selected, barMetrics: .default)
		self.segmentedControl.setDividerImage(UIImage(named: "segmentDivider"), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
		
		self.segmentedControl.autoresizingMask = UIViewAutoresizing(rawValue: UIViewAutoresizing.flexibleTopMargin.rawValue | UIViewAutoresizing.flexibleBottomMargin.rawValue | UIViewAutoresizing.flexibleLeftMargin.rawValue | UIViewAutoresizing.flexibleRightMargin.rawValue)
		let containerView = UIView(frame: self.segmentedControl.frame)
		containerView.addSubview(self.segmentedControl)
		containerView.frame = self.contentView.bounds
		containerView.autoresizingMask = UIViewAutoresizing(rawValue: UIViewAutoresizing.flexibleWidth.rawValue | UIViewAutoresizing.flexibleHeight.rawValue)
		self.contentView.addSubview(containerView)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

class TTTProfileStatisticsTableViewCell: UITableViewCell {
	
	var countView: TTTCountView!
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		
		self.countView = TTTCountView(frame: CGRect(x: 0, y: 0, width: 160.0, height: 20.0))
		self.accessoryView = self.countView
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
}


