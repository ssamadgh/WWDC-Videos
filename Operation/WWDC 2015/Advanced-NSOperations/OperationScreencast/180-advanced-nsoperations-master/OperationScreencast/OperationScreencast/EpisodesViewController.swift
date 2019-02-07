//
//  EpisodesViewController.swift
//  OperationScreencast
//
//  Created by Ben Scheirman on 7/21/15.
//  Copyright (c) 2015 NSScreencast. All rights reserved.
//

import UIKit
import CoreData
import JMImageCache

class EpisodesViewController : UITableViewController, NSFetchedResultsControllerDelegate {
	
	var context: NSManagedObjectContext?
	var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?
	let operationQueue = OperationQueue()
	var loadModelOperation: LoadDataModelOperation?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		refreshControl = UIRefreshControl()
		refreshControl!.addTarget(self, action: #selector(refresh), for: .valueChanged)
		
		loadModel()
	}
	
	func loadModel() {
		let loadOperation = LoadDataModelOperation {
			context in
			
			self.context = context
			if AuthStore.instance.isLoggedIn() {
				self.loadEpisodes()
			} else {
				self.login()
			}
		}
		operationQueue.addOperation(loadOperation)
	}
	
	func login() {
		let loginOperation = LoginOperation()
		loginOperation.completionBlock = {
			self.refresh()
		}
		operationQueue.addOperation(loginOperation)
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if let sectionInfo = fetchedResultsController?.sections?[section] {
			return sectionInfo.numberOfObjects
		}
		
		return 0
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "EpisodeTableViewCell", for: indexPath) as! EpisodeTableViewCell
		
		let episode = fetchedResultsController!.object(at: indexPath) as! Episode
		cell.titleLabel.text = episode.title
		cell.subtitleLabel.text = "\(episode.episodeNumber)"
		cell.artworkImageView.setImageWith(URL(string: episode.artworkUrl)!)
		
		return cell
	}
	
	private func loadEpisodes() {
		print("Fetching episodes from local store...")
		let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Episode")
		fetchRequest.sortDescriptors = [NSSortDescriptor(key: "episodeNumber", ascending: false)]
		fetchRequest.fetchBatchSize = 100
		fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context!, sectionNameKeyPath: nil, cacheName: nil)
		fetchedResultsController!.delegate = self
		try? fetchedResultsController!.performFetch()
		tableView.reloadData()
	}
	
	func refresh() {
		DispatchQueue.main.async {
			self.refreshControl?.beginRefreshing()
		}
		
		let cachesDir = try! FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
		let path = cachesDir.appendingPathComponent("episodes.json").path
		let downloadEpisodesOperation = DownloadEpisodesOperation(path: path, context: context!)
		downloadEpisodesOperation.completionBlock = { [weak self] in
			DispatchQueue.main.async {
				self?.refreshControl?.endRefreshing()
				if let error = downloadEpisodesOperation.error {
					let alert = UIAlertController(title: "Error downloading episodes", message: error.localizedDescription, preferredStyle: .alert)
					alert.addAction(UIAlertAction(title: "Abort", style: .cancel, handler: nil))
					alert.addAction(UIAlertAction(title: "Retry", style: .default, handler: { action in
						self?.refresh()
					}))
				} else {
					self?.loadEpisodes()
				}
			}
		}
		operationQueue.addOperation(downloadEpisodesOperation)
	}
	
	@IBAction func destroyState(_ sender: AnyObject) {
		AuthStore.instance.logout()
		fetchedResultsController = nil
		context = nil
		tableView.reloadData()
		
		if let storeURL = loadModelOperation?.storeURL {
			try! FileManager.default.removeItem(at: storeURL)
		}
		
		loadModel()
	}
	
	func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		self.tableView.reloadData()
	}
	
}
