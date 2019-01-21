//
//  MainViewController.swift
//  CollectionView
//
//  Created by Andrea Prearo on 8/19/16.
//  Copyright © 2016 Andrea Prearo. All rights reserved.
//

import UIKit
import ModelAssistant

extension UserViewModel: MAFaultable {
	
	var isFoult: Bool {
		
		get {
			return self.image == nil
		}
		
		set(newValue) {
			
		}
	}
	
	mutating func fault() {
		if !self.isFoult {
			self.image = nil
		}
	}
	
	mutating func fire() {
		
	}
	
	
}




class MainViewController: UICollectionViewController {
	
	var insertingNewEntities = false
	
	private static let sectionInsets = UIEdgeInsetsMake(0, 2, 0, 2)
	
	private var userViewModelController: UserViewModelControllerNew!
	
	// Pre-Fetching Queue
	//    private let imageLoadQueue = OperationQueue()
	//    private var imageLoadOperations = [IndexPath: ImageLoadOperation]()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.userViewModelController = UserViewModelControllerNew(controller: self)
		
		Feature.initFromPList()
		if Feature.clearCaches.isEnabled {
			let cachesFolderItems = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)
			for item in cachesFolderItems {
				try? FileManager.default.removeItem(atPath: item)
			}
		}
		
		if #available(iOS 10.0, *) {
			collectionView?.prefetchDataSource = self
		}
		userViewModelController.retrieveUsers { [weak self] (success, error) in
			guard let strongSelf = self else { return }
			if !success {
				DispatchQueue.main.async {
					let title = "Error"
					if let error = error {
						strongSelf.showError(title, message: error.localizedDescription)
					} else {
						strongSelf.showError(title, message: NSLocalizedString("Can't retrieve contacts.", comment: "Can't retrieve contacts."))
					}
				}
			} else {
				//                DispatchQueue.main.async {
				//                    strongSelf.collectionView?.reloadData()
				//                }
			}
		}
	}
	
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		print("Memory Warning")
		if let visibleRows = self.collectionView?.indexPathsForVisibleItems, !visibleRows.isEmpty {
			let sectionIndex = visibleRows.first!.section
			let firstRow = visibleRows.first!.row
			
			self.userViewModelController.assistant.fault(at: sectionIndex, in: 0..<firstRow)
		}
	}

	
	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)
		coordinator.animate(alongsideTransition: { [weak self] context in
			self?.collectionView?.collectionViewLayout.invalidateLayout()
			}, completion: nil)
	}
	
	@IBAction func displayOverlayTapped(_ sender: Any) {
		showDebuggingInformationOverlay()
	}
	
}

// MARK: -
private extension MainViewController {
	func showDebuggingInformationOverlay() {
		guard let overlayClass = NSClassFromString("UIDebuggingInformationOverlay") as? UIWindow.Type else { return }
		_ = overlayClass.perform(NSSelectorFromString("prepareDebuggingOverlay"))
		guard let overlay = overlayClass.perform(NSSelectorFromString("overlay"))?.takeUnretainedValue() as? UIWindow else { return }
		_ = overlay.perform(NSSelectorFromString("toggleVisibility"))
	}
}

// MARK: UICollectionViewDataSource
extension MainViewController {
	
	override func numberOfSections(in collectionView: UICollectionView) -> Int {
		return userViewModelController.numberOfSections
	}
	
	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return userViewModelController.numberOfRows(at: section)
	}
	
	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UserCell", for: indexPath) as! UserCell
		self.configure(cell, at: indexPath)
		
		if Feature.debugCellLifecycle.isEnabled {
			print(String.init(format: "cellForRowAt #%i", indexPath.row))
		}
		
		return cell
	}
	
	func configure(_ cell: UICollectionViewCell, at indexPath: IndexPath) {
		guard let viewModel = userViewModelController.viewModel(at: indexPath),
			let cell = cell as? UserCell else { return }
		print("configure indexPath \(indexPath.row) for name \(viewModel.username)")

		cell.configure(viewModel)
		
		//New process for downloading image
//		if viewModel.needsToDownloadImage {
			userViewModelController.downloadOperation(for: viewModel, at: indexPath)
//		}
		
	}
	
	override func update(_ cell: UICollectionViewCell, at indexPath: IndexPath) {
		guard let viewModel = userViewModelController.viewModel(at: indexPath),
			let cell = (cell as? UserCell) else {
				print("canceled update for indexPath \(indexPath.row)")
				
				return
		}
		print("update indexPath \(indexPath.row) for name \(viewModel.username)")
		
		UIView.transition(with: cell.avatar, duration: 0.2, options: .transitionCrossDissolve, animations: {
			cell.avatar.setRoundedImage(viewModel.image)
		}, completion: nil)
	}
	
	
	
	func updateOnScreenRows() {
		let visiblePaths = self.collectionView?.indexPathsForVisibleItems ?? []
		for indexPath in visiblePaths {
			checkForUpdate(at: indexPath)
		}
	}
	
	func checkForUpdate(at indexPath: IndexPath) {
			if (self.collectionView?.isDragging == false && self.collectionView?.isDecelerating == false)
			{
				userViewModelController.downloadOperation(at: indexPath)

			}

		}
	
//	override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
//		if !decelerate {
//			self.updateOnScreenRows()
//		}
//	}
//
//	override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//		self.updateOnScreenRows()
//	}

	
	
	
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		guard let viewModel = userViewModelController.viewModel(at: indexPath),
			let cell = collectionView.cellForItem(at: indexPath) as? UserCell else { return }
		
		print("didSelect indexPath \(indexPath.row) for name \(viewModel.username)")
	}
	
	override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		if Feature.debugCellLifecycle.isEnabled {
			print(String.init(format: "willDisplay #%i", indexPath.row))
		}
	}
	
	override func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//		userViewModelController.cancelOperation(for: indexPath)
		
		if Feature.debugCellLifecycle.isEnabled {
			print(String.init(format: "didEndDisplaying #%i", indexPath.row))
		}
	}
}

// MARK: UICollectionViewDelegateFlowLayout protocol methods
extension MainViewController: UICollectionViewDelegateFlowLayout {
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
		let columns: Int = {
			var count = 2
			if traitCollection.horizontalSizeClass == .regular {
				count = count + 1
			}
			if collectionView.bounds.width > collectionView.bounds.height {
				count = count + 1
			}
			return count
		}()
		let totalSpace = flowLayout.sectionInset.left
			+ flowLayout.sectionInset.right
			+ (flowLayout.minimumInteritemSpacing * CGFloat(columns - 1))
		let size = Int((collectionView.bounds.width - totalSpace) / CGFloat(columns))
		return CGSize(width: size, height: 90)
	}
}

// MARK: UICollectionViewDataSourcePrefetching
extension MainViewController: UICollectionViewDataSourcePrefetching {
	
	func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
		for indexPath in indexPaths {
			userViewModelController.downloadOperation(at: indexPath)

			if Feature.debugCellLifecycle.isEnabled {
				print(String.init(format: "prefetchItemsAt #%i", indexPath.row))
			}
		}
	}
	
	func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
		for indexPath in indexPaths {
			userViewModelController.cancelOperation(for: indexPath)

			if Feature.debugCellLifecycle.isEnabled {
				print(String.init(format: "cancelPrefetchingForItemsAt #%i", indexPath.row))
			}
		}
	}
	
}

extension MainViewController {
	
	override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
		if !decelerate {
			self.insertEntities()
			self.updateOnScreenRows()

		}
	}
	
	override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
		self.insertEntities()
		self.updateOnScreenRows()

	}
	
	func insertEntities() {
		
		guard !insertingNewEntities else {
			return
		}
		
		let tableViewHeight = self.collectionView!.bounds.height
		let maxOffsetHeight = self.collectionView!.contentSize.height - tableViewHeight - 100
		let offsetY = self.collectionView!.contentOffset.y
		if offsetY >= maxOffsetHeight {
			self.insertingNewEntities = true
			self.userViewModelController.loadNextPageIfNeeded {
				self.insertingNewEntities = false
			}
		}
	}
	
}
