/*
  RootViewController.swift
  LazyTable

  Created by Seyed Samad Gholamzadeh on 6/26/18.
  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.

Abstract: Controller for the main table view of the LazyTable sample.
This table view controller works off the AppDelege's data model.
produce a three-stage lazy load:
1. No data (i.e. an empty table)
2. Text-only data from the model's RSS feed
3. Images loaded over the network asynchronously

This process allows for asynchronous loading of the table to keep the UI responsive.
Stage 3 is managed by the AppRecord corresponding to each row/cell.

Images are scaled to the desired height.
If rapid scrolling is in progress, downloads do not begin until scrolling has ended.

*/

import UIKit

let kCustomRowHeight: CGFloat = 60.0
let kCustomRowCount: Int = 7


class RootViewController: UITableViewController, IconDownloaderDelegate {

	var entries: [AppRecord]!   // the main data model for our UITableView
	var imageDownloadsInProgress: [IndexPath : IconDownloader]!  // the set of IconDownloader objects for each app
	
    override func viewDidLoad() {
        super.viewDidLoad()

		self.imageDownloadsInProgress = [:]
		self.tableView.rowHeight = kCustomRowHeight
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

		// terminate all pending download connections
		_ = self.imageDownloadsInProgress.values.map { $0.cancelDownload() }
		
	}

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
		let count = self.entries?.count ?? 0
		
		if count == 0 {
			return kCustomRowCount
		}
        return count
    }
	

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		// customize the appearance of table view cells
		//
		let CellIdentifier = "LazyTableCell"
		let PlaceholderCellIdentifier = "PlaceholderCell"
		
		// add a placeholder cell while waiting on table data
		let nodeCount = self.entries?.count ?? 0
		
		if nodeCount == 0 && indexPath.row == 0 {
			let cell = tableView.dequeueReusableCell(withIdentifier: PlaceholderCellIdentifier, for: indexPath)
			cell.detailTextLabel?.textAlignment = NSTextAlignment.center
			cell.selectionStyle = UITableViewCellSelectionStyle.none
			cell.detailTextLabel?.text = "Loading…"
			
			return cell

		}
		
		let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier, for: indexPath)
		
		
		// Leave cells empty if there's no data yet
		if nodeCount > 0 {
			// Set up the cell...
			let appRecord = self.entries[indexPath.row]
			cell.textLabel?.text = appRecord.appName
			cell.detailTextLabel?.text = appRecord.artist

			// Only load cached images; defer new downloads until scrolling ends
			if appRecord.appIcon == nil
			{
				if (self.tableView.isDragging == false && self.tableView.isDecelerating == false)
				{
					self.startIconDownload(appRecord, for: indexPath)
				}

				// if a download is deferred or in progress, return a placeholder image
				cell.imageView?.image = UIImage(named: "Placeholder")
			}
			else
			{
				cell.imageView?.image = appRecord.appIcon
			}

		}

        return cell
    }
	
	//MARK: - Table cell image support
	func startIconDownload(_ appRecord: AppRecord, for indexPath: IndexPath) {
		var iconDownloader: IconDownloader! = imageDownloadsInProgress[indexPath]
		if iconDownloader == nil {
			iconDownloader = IconDownloader()
			iconDownloader.appRecord = appRecord
			iconDownloader.indexPathInTableView = indexPath
			iconDownloader.delegate = self
			imageDownloadsInProgress[indexPath] = iconDownloader
			iconDownloader.startDownload()
		}
	}
	
	// this method is used in case the user scrolled into a set of cells that don't have their app icons yet
	func loadImagesForOnscreenRows() {
		if self.entries.count > 0 {
			let visiblePaths = self.tableView.indexPathsForVisibleRows ?? []
			for indexPath in visiblePaths {
				let appRecord = self.entries[indexPath.row]
				if appRecord.appIcon == nil // avoid the app icon download if the app already has an icon
				{
					self.startIconDownload(appRecord, for: indexPath)
				}
			}
		}
	}
	
	// called by our ImageDownloader when an icon is ready to be displayed
	func appImageDidLoad(_ indexPath: IndexPath) {
		if let iconDownloader = imageDownloadsInProgress[indexPath],
			let cell = self.tableView.cellForRow(at: indexPath) {
			
			// Display the newly loaded image
			cell.imageView?.image = iconDownloader.appRecord.appIcon
		}
		
		// Remove the IconDownloader from the in progress list.
		// This will result in it being deallocated.
		self.imageDownloadsInProgress.removeValue(forKey: indexPath)
	}
	
	//MARK: - Deferred image loading (UIScrollViewDelegate)
	
	override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
		if !decelerate {
			self.loadImagesForOnscreenRows()
		}
	}
	override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
		self.loadImagesForOnscreenRows()
	}
}
