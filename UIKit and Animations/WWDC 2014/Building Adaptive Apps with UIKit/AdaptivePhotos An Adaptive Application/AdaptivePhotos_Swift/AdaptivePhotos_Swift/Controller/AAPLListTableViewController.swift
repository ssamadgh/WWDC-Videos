/*
Copyright (C) 2014 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:

A view controller that shows a list of conversations that can be viewed.

*/

import UIKit

class AAPLListTableViewController: UITableViewController {

	var user: AAPLUser! {
		didSet {
			if self.isViewLoaded {
				self.tableView.reloadData()
			}
		}
	}
	
	init() {
		super.init(style: .plain)
		
		self.title = NSLocalizedString("Conversations", comment: "Conversations")
		self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Profile", comment: "Profile"), style: .plain, target: self, action: #selector(showProfile(_:)))
	}
	
	override convenience init(style: UITableViewStyle) {
		self.init()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIViewControllerShowDetailTargetDidChange, object: nil)
	}
	
	let AAPLListTableViewControllerCellIdentifier = "Cell"
	
    override func viewDidLoad() {
        super.viewDidLoad()
		self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: AAPLListTableViewControllerCellIdentifier)
		
		NotificationCenter.default.addObserver(self, selector: #selector(showDetailTargetDidChange(_:)), name: NSNotification.Name.UIViewControllerShowDetailTargetDidChange, object: nil)
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		for indexPath in self.tableView.indexPathsForSelectedRows ?? [] {
			let pushes: Bool
			if self.shouldShowConversationView(for: indexPath) {
				pushes = true
			}
			else {
				pushes = true
			}
			
			if (pushes) {
				// If we're pushing for this indexPath, deselect it when we appear
				self.tableView.deselectRow(at: indexPath, animated: animated)
			}

		}
	}
	
	@objc func showDetailTargetDidChange(_ notification: Notification) {
		// Whenever the target for showDetailViewController: changes, update all of our cells (to ensure they have the right accessory type)
		for cell in self.tableView.visibleCells {
			if let indexPath = self.tableView.indexPath(for: cell) {
			self.tableView(self.tableView, willDisplay: cell, forRowAt: indexPath)
			}
		}
	}
	
	override func aapl_contains(_ photo: AAPLPhoto) -> Bool {
		return true
	}
	
	@objc func showProfile(_ sender: UIBarButtonItem) {
		let controller = AAPLProfileViewController()
		controller.user = self.user
		controller.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(closeProfile(_:)))
		let navController =  UINavigationController(rootViewController: controller)
		navController.modalPresentationStyle = UIModalPresentationStyle.popover
		navController.popoverPresentationController?.barButtonItem = sender
		navController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.any
		self.present(navController, animated: true, completion: nil)
	}
	
	@objc func closeProfile(_ sender: Any) {
		self.dismiss(animated: true, completion: nil)
	}
	
    // MARK: - Table view data source
	
	func conversation(for indexPath: IndexPath) -> AAPLConversation {
		return self.user.conversations[indexPath.row]
	}
	
	func shouldShowConversationView(for indexPath: IndexPath) -> Bool {
		let conversation = self.conversation(for: indexPath)
		return conversation.photos.count != 1
	}

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.user.conversations.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AAPLListTableViewControllerCellIdentifier, for: indexPath)

        // Configure the cell...

        return cell
    }

	override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		
		let pushes: Bool
		
		if self.shouldShowConversationView(for: indexPath) {
			pushes = self.aapl_willShowingViewControllerPush(sender: self)
		}
		else {
			pushes = self.aapl_willShowingDetailViewControllerPush(sender: self)
		}
		
		// Only show a disclosure indicator if we're pushing
		if pushes {
			cell.accessoryType = .disclosureIndicator
		}
		else {
			cell.accessoryType = .none
		}
		
		let conversation = self.conversation(for: indexPath)
		cell.textLabel?.text = conversation.name
		
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		let conversation = self.conversation(for: indexPath)
		if self.shouldShowConversationView(for: indexPath) {
			let controller = AAPLConversationViewController()
			controller.conversation = conversation
			controller.title = conversation.name
			
			// If this row has a conversation, we just want to show it
			self.show(controller, sender: self)
		}
		else {
			let photo = conversation.photos.last
			let controller = AAPLPhotoViewController()
			controller.photo = photo
			controller.title = conversation.name
			
			// If this row has a single photo, then show it as the detail (if possible)
			self.showDetailViewController(controller, sender: self)
		}
	}
	
}





