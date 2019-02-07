//
//  DownloadEpisodesOperation.swift
//  OperationScreencast
//
//  Created by Ben Scheirman on 7/21/15.
//  Copyright (c) 2015 NSScreencast. All rights reserved.
//

import Foundation
import CoreData

class DownloadEpisodesOperation : ASOperation {
    var path: String
    var error: NSError?
    let context: NSManagedObjectContext
    
    private var internalQueue = OperationQueue()
    
    init(path: String, context: NSManagedObjectContext) {
        self.path = path
        self.context = context
    }
    
    override func execute() {
		if FileManager.default.fileExists(atPath: path) {
			try! FileManager.default.removeItem(atPath: path)
        }
        
		internalQueue.isSuspended = true
        
        let fetchOperation = FetchRemoteEpisodesOperation(path: path)
        let importOperation = ImportEpisodesOperation(path: path, context: context)
        importOperation.addDependency(fetchOperation)
        
        internalQueue.addOperation(fetchOperation)
        internalQueue.addOperation(importOperation)
        
		let finalOperation = BlockOperation(block: {
            self.finish()
        })
        
        finalOperation.addDependency(importOperation)
        internalQueue.addOperation(finalOperation)
        
		internalQueue.isSuspended = false
    }
}
