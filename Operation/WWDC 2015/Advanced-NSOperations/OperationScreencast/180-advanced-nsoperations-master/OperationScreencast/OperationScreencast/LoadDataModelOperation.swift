//
//  LoadDataModelOperation.swift
//  OperationScreencast
//
//  Created by Ben Scheirman on 7/21/15.
//  Copyright (c) 2015 NSScreencast. All rights reserved.
//

import Foundation
import CoreData

class LoadDataModelOperation : ASOperation {
	
	let loadHandler: ((NSManagedObjectContext) -> Void)
    var context: NSManagedObjectContext?
    
	init(loadHandler: @escaping (NSManagedObjectContext) -> Void) {
        self.loadHandler = loadHandler
        super.init()
    }
    
    var cachesFolder: URL {
		return try! FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    }
    
    var storeURL: URL {
        return cachesFolder.appendingPathComponent("episodes.sqlite")
    }
    
    lazy var model: NSManagedObjectModel = {
		return NSManagedObjectModel.mergedModel(from: nil)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        return NSPersistentStoreCoordinator(managedObjectModel: self.model)
    }()
    
    override func execute() {
		
		do {
			try persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: nil)
		} catch {
			print("Couldn't create store")
			abort()
		}
		        
		DispatchQueue.main.async {
            self.context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
            self.context!.persistentStoreCoordinator = self.persistentStoreCoordinator
            
            self.loadHandler(self.context!)
            self.finish()
        }
    }
}
