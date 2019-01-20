/*
Copyright (C) 2014 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:

A view controller that shows the contents of a conversation.

*/

import UIKit

class AAPLConversationViewController: UITableViewController {

	var conversation: AAPLConversation!
	
	init() {
		super.init(style: .plain)
		self.clearsSelectionOnViewWillAppear = false
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
	
	let AAPLConversationViewControllerCellIdentifier = "Cell"
	
    override func viewDidLoad() {
        super.viewDidLoad()

		self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: AAPLConversationViewControllerCellIdentifier)
		
		NotificationCenter.default.addObserver(self, selector: #selector(showDetailTargetDidChange(_:)), name: NSNotification.Name.UIViewControllerShowDetailTargetDidChange, object: nil)

    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		for indexPath in self.tableView.indexPathsForSelectedRows ?? [] {
			let indexPathPushes = self.aapl_willShowingDetailViewControllerPush(sender: self)
			
			if indexPathPushes {
				// If we're pushing for this indexPath, deselect it when we appear
				self.tableView.deselectRow(at: indexPath, animated: animated)
			}
		}
		
		
		if let visiblePhoto = self.aapl_currentVisibleDetailPhoto(sender: self) {
			for indexPath in self.tableView.indexPathsForVisibleRows! {
				let photo = self.photo(for: indexPath)
				if (photo == visiblePhoto) {
					self.tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
				}

			}
		}
		
	}
	
	override func aapl_contains(_ photo: AAPLPhoto) -> Bool {
		return self.conversation.photos.contains(photo)
	}
	
	@objc func showDetailTargetDidChange(_ notification: Notification) {
		// Whenever the target for showDetailViewController: changes, update all of our cells (to ensure they have the right accessory type)
		for cell in self.tableView.visibleCells {
			if let indexPath = self.tableView.indexPath(for: cell) {
				self.tableView(self.tableView, willDisplay: cell, forRowAt: indexPath)
			}
		}
	}

    // MARK: - Table view data source

	func photo(for indexPath: IndexPath) -> AAPLPhoto {
		return self.conversation.photos[indexPath.row]
	}
	
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.conversation.photos.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AAPLConversationViewControllerCellIdentifier, for: indexPath)

        // Configure the cell...

        return cell
    }

	override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		
		let pushes = self.aapl_willShowingDetailViewControllerPush(sender: self)
		
		// Only show a disclosure indicator if we're pushing
		if pushes {
			cell.accessoryType = .disclosureIndicator
		} else {
			cell.accessoryType = .none
		}
		
		let photo = self.photo(for: indexPath)
		cell.textLabel?.text = photo.comment
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let photo = self.photo(for: indexPath)
		let controller = AAPLPhotoViewController()
		controller.photo = photo
		let photoNumber = indexPath.row + 1
		let photoCount = self.conversation.photos.count
		controller.title = String.init(format: NSLocalizedString("%ld of %ld", comment: "%ld of %ld"), photoNumber, photoCount)
		
		// Show the photo as the detail (if possible)
		self.showDetailViewController(controller, sender: self)
	}
	
}
