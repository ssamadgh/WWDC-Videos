//
//  BasicCollectionViewPresenter.swift
//  CoreDataBooks_Swift
//
//  Created by Seyed Samad Gholamzadeh on 2/4/19.
//  Copyright © 2019 Seyed Samad Gholamzadeh. All rights reserved.
//

import Foundation
import AOperation
import CoreData

class BasicCollectionViewPresenter<Entity: NSManagedObject>: BasicPresenter {
	
	var operationQueue: AOperationQueue

	var resultsController: NSFetchedResultsController<Entity>?
	private var manager: FetchedResultsControllerDelegateManager!
	
	
	init(operationQueue: AOperationQueue) {
		self.operationQueue = operationQueue
	}
	
	func fetchInitialEntities(withSectionKey sectionKey: String?, for controller: CollectionController, completion: @escaping (_ isEmpty: Bool) -> Void) {
		
		let configureOp = BlockAOperation { finished in
			let request = NSFetchRequest<Entity>(entityName: String(describing: Entity.self))
			let authorSort = NSSortDescriptor(key: "author", ascending: true)
			let titleSort = NSSortDescriptor(key: "title", ascending: true)
			request.sortDescriptors = [authorSort, titleSort]
			let context = CDStack.viewContext
			self.resultsController = NSFetchedResultsController<Entity>(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: sectionKey, cacheName: nil)
			self.manager = FetchedResultsControllerDelegateManager(controller: controller)
			self.resultsController?.delegate = self.manager
			
			finished()
		}
		
		configureOp.addCondition(CoreDataStackAvailablity())
		
		let fetchOp = BlockAOperation { finished in
			do {
				try self.resultsController?.performFetch()
			} catch {
				fatalError("Failed to initialize FetchedResultsController: \(error)")
			}
			let isEmpty = (self.resultsController?.fetchedObjects ?? []).isEmpty
			DispatchQueue.main.async {
				completion(isEmpty)
			}
			finished()
		}
		
		fetchOp.addDependency(configureOp)
		
		let groupOp = GroupOperation(operations: configureOp, fetchOp)
		self.operationQueue.addOperation(groupOp)
		
	}
	
	var numberOfSections: Int {
		if let count = self.resultsController?.sections?.count {
			return count
		}
		return 0
	}
	
	func numberOfEntities(at section: Int) -> Int {
		var numberOfRows = 0
		
		if let count = self.resultsController?.sections?.count, count > 0 {
			if let sectionInfo = self.resultsController?.sections?[section] {
				numberOfRows = sectionInfo.numberOfObjects
			}
		}
		
		return numberOfRows;
	}
	
	subscript(_ indexPath: IndexPath) -> Entity? {
		return self.resultsController?.object(at: indexPath)
	}
	
	subscript(_ index: Int) -> NSFetchedResultsSectionInfo? {
		return self.resultsController?.sections?[index]
	}

	func deleteObject(at indexPath: IndexPath) {
		let context = self.resultsController?.managedObjectContext
		if let object = self[indexPath] {
			context?.delete(object)
			try? context?.save()
		}
	}
	
}
