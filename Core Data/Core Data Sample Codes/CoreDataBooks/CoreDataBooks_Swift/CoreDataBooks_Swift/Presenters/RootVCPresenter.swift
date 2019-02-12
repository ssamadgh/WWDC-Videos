//
//  RootVCPresenter.swift
//  CoreDataBooks_Swift
//
//  Created by Seyed Samad Gholamzadeh on 2/3/19.
//  Copyright © 2019 Seyed Samad Gholamzadeh. All rights reserved.
//

import Foundation
import CoreData
import AOperation

class RootVCPresenter: BasicCollectionViewPresenter<Book>, AddVCPresenterDelegate {
	
	func prepare(_ vc: AddViewController) {
		let addingContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
		addingContext.parent = self.resultsController?.managedObjectContext
		
		let newBook = Book(context: addingContext)
		let presenter = AddVCPresenter(operationQueue: self.operationQueue, book: newBook)
		presenter.delegate = self
		presenter.managedObjectContext = addingContext
		vc.presenter = presenter
	}
	
	func prepare(_ vc: ShowViewController, for indexPath: IndexPath) {
		if let selectedBook = self[indexPath] {
			vc.presenter = DetailVCPresenter(operationQueue: self.operationQueue, book: selectedBook)
		}
	}
	
	func addVCPresenter(_ presenter: AddVCPresenter, didFinishWithSave save: Bool) {
		if save {
			
			let op = BlockAOperation { finish in
				let addingManagedObjectContext = presenter.managedObjectContext
				
				addingManagedObjectContext?.perform {
					do {
						try addingManagedObjectContext?.save()
						
						self.resultsController?.managedObjectContext.performAndWait {
							try? self.resultsController?.managedObjectContext.save()

						}
					}
					catch {
						
					}

				}
				
			}
			
			self.operationQueue.addOperation(op)
		}

	}


	
}
