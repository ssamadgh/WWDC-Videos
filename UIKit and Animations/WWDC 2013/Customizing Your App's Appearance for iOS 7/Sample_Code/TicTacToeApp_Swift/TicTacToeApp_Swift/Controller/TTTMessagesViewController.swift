//
//  TTTMessagesViewController.swift
//  TicTacToeApp_Swift
//
//  Created by Seyed Samad Gholamzadeh on 7/12/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

class TTTMessagesViewController: UITableViewController {

	var profile: TTTProfile!
	var selectedMessage: TTTMessage!
	
	let CellIdentifier = "Cell"
	
	static func viewController(with profile: TTTProfile, profileURL: URL) -> UIViewController {
		
		let controller: TTTMessagesViewController = TTTMessagesViewController()
		controller.profile = profile
		let navController = UINavigationController(rootViewController: controller)
		return navController
	}
	
	init() {
		super.init(style: .plain)
		
		self.title = NSLocalizedString("Messages", comment: "Messages")
		self.tabBarItem.image = UIImage(named: "messagesTab")
		self.tabBarItem.selectedImage = UIImage(named: "messagesTabSelected")
		self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(newMessage(_:)))
		NotificationCenter.default.addObserver(self, selector: #selector(didAddMessages(_:)), name: NSNotification.Name(rawValue: TTTMessageServerDidAddMessagesNotification), object: TTTMessageServer.shared)
		self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: nil, style: .plain, target: self, action: #selector(favorite(_:)))
		self.updateFavoriteButton()
	}
	
	override convenience init(style: UITableViewStyle) {
		self.init()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()

		self.tableView.register(TTTMessageTableViewCell.self, forCellReuseIdentifier: CellIdentifier)
	}
	
//	override func viewDidAppear(_ animated: Bool) {
//		super.viewDidAppear(animated)
//		self.view.window!.tintAdjustmentMode = .dimmed
//	}
	
	@objc func newMessage(_ sender: Any) {
		let controller = TTTNewMessageViewController()
		controller.profile = self.profile
		controller.present(from: self)
	}
	
	@objc func didAddMessages(_ notification: Notification) {
		let addedIndexes = notification.userInfo![TTTMessageServerAddedMessageIndexesUserInfoKey] as! [Int]
		var addedIndexPaths: [IndexPath] = []
		
		for indexValue in addedIndexes {
			let indexPath = IndexPath(row: indexValue, section: 0)
			addedIndexPaths.append(indexPath)
		}
		
		self.tableView.insertRows(at: addedIndexPaths, with: .automatic)
	}

	@objc func favorite(_ sender: Any) {
		var favorite = TTTMessageServer.shared.isFavorite(self.selectedMessage)
		favorite = !favorite
		TTTMessageServer.shared.setFavorite(favorite, for: self.selectedMessage)
		self.updateFavoriteButton()
	}

	func updateFavoriteButton() {
		var isFavorite = false
		
		if self.selectedMessage != nil {
			isFavorite = TTTMessageServer.shared.isFavorite(self.selectedMessage)
		}
		
		let image: UIImage
		if isFavorite {
			image = UIImage(named: "favorite")!.withRenderingMode(.alwaysOriginal)
		}
		else {
			image = UIImage(named: "favoriteUnselected")!
		}
		
		self.navigationItem.leftBarButtonItem?.image = image
		self.navigationItem.leftBarButtonItem?.isEnabled = (self.selectedMessage != nil)
	}


    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return TTTMessageServer.shared.numberOfMessages
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier, for: indexPath)

        // Configure the cell...

        return cell
    }
	
	override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		let message = TTTMessageServer.shared.message(at: indexPath.row)
		cell.textLabel?.text = message.text
		cell.imageView?.image = TTTProfile.smallImage(for: message.icon)
		
		if (cell as! TTTMessageTableViewCell).replyButton == nil {
			let replyButton = UIButton(type: .system)
			replyButton.addTarget(self, action: #selector(newMessage(_:)), for: .touchUpInside)
			replyButton.setImage(UIImage(named: "reply"), for: .normal)
			replyButton.sizeToFit()
			(cell as! TTTMessageTableViewCell).replyButton = replyButton
		}
		
		let isSelected = self.tableView.indexPathForSelectedRow == indexPath
		(cell as! TTTMessageTableViewCell).showReplyButton = isSelected
	}

	override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
			let cell = tableView.cellForRow(at: indexPath) as! TTTMessageTableViewCell
		cell.showReplyButton = false
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let message = TTTMessageServer.shared.message(at: indexPath.row)
		let cell = tableView.cellForRow(at: indexPath) as! TTTMessageTableViewCell
		
		if self.selectedMessage == message {
			self.tableView.deselectRow(at: indexPath, animated: true)
			self.selectedMessage = nil
			cell.showReplyButton = false
		}
		else {
			self.selectedMessage = message
			cell.showReplyButton = true
		}
		self.updateFavoriteButton()
	}
	
}

class TTTMessageTableViewCell: UITableViewCell {
	var replyButton: UIButton!
	var showReplyButton: Bool = false {
		didSet {
			self.accessoryView = showReplyButton ? self.replyButton : nil
		}
	}
	
	
}
