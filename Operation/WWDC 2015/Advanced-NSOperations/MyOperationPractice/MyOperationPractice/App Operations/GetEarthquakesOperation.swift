/*
  GetEarthquakesOperation.swift
  OperationPractice

  Created by Seyed Samad Gholamzadeh on 7/3/1396 AP.
  Copyright © 1396 AP Seyed Samad Gholamzadeh. All rights reserved.
 
 Abstract:
     This file sets up the operation to download and parse earthquakes data. It will also decide to display an error message, if approperiate.
*/

import Foundation
import CoreData

/// A composite `AOperation` to both download and parse earthquake data.
class GetEarthquakesOperation: GroupOperation {
    //MARK: Properties
    
    let downloadOperation: DownloadEarthquakesOperation
    let parseOperation: ParseEarthquakesOperation
    
    fileprivate var hasProducedAlert = false
    
    /**
     - parameter context: The `NSManagedObjectContext` into wich the parsed earthquakes will be imported.
     
     - parameter completionHandler: The Handler to call after downloading and parsing are complete.
         The handler will be invoked on an arbitrary queue.
    */
    init(context: NSManagedObjectContext, completionHandler: @escaping () -> Void) {
        let cachesFolder = try! FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let cacheFile = cachesFolder.appendingPathComponent("earthquakes.json")
        
        /*
         This operation is made for three child operation:
             1. The operation to download the JSON feed
             2. The operation to parse the JSON feed and insert the elements into the Core Data store
             3. The operation to invoke the completion handler
        */
        downloadOperation = DownloadEarthquakesOperation(cacheFile: cacheFile)
        parseOperation = ParseEarthquakesOperation(cacheFile: cacheFile, context: context)
        
        let finishOperation = Foundation.BlockOperation(block: completionHandler)
        
        // These operations must be executed in order
        parseOperation.addDependency(downloadOperation)
        finishOperation.addDependency(parseOperation)
        
        super.init(operations: [downloadOperation, parseOperation, finishOperation])
        
        name = "Get Earthquakes"
    }
    
    override func operationDidFinish(_ operation: Foundation.Operation, withErrors errors: [NSError]) {
        if let firstError = errors.first, (operation === downloadOperation || operation === parseOperation) {
            produceAlert(firstError)
        }
    }
    
    fileprivate func produceAlert(_ error: NSError) {
        /*
             We only want to show the first Error, since subsequent errors might be caused
             by the first.
        */
        if hasProducedAlert { return }
        
        let alert = AlertOperation()
        
        let errorReason = (error.domain, error.code, error.userInfo[OperationConditionKey] as? String)
        
        //These are example of errors for which we might choose to display an error to the user
        let failedReachability = (OperationErrorDomain, OperationErrorCode.conditionFailed, ReachabilityCondition.name)
        
        let failedJSON = (NSCocoaErrorDomain, NSPropertyListReadCorruptError, nil as String?)
        
        switch errorReason {
        case failedReachability:
            // We failed because the network isn't reachable.
            let hostURL = error.userInfo[ReachabilityCondition.hostKey] as! URL
            
            alert.title = "Unable to Connect"
            alert.message = "Cannot connect to \(hostURL.host!). Make sure your device is connected to the internet and try again."
        case failedJSON:
            // We failed because the JSON was malformed.
            alert.title = "Unable to Download"
            alert.message = "Cannot Download earthquake data. try again later."
        default:
            return
        }
        
        produceOperation(alert)
        hasProducedAlert = true
    }
}

// Operators to use in the switch statement.
private func ~=(lhs: (String, Int, String?), rhs: (String, Int, String?)) -> Bool {
    return lhs.0 ~= rhs.0 && lhs.1 ~= rhs.1 && lhs.2 == rhs.2
}

private func ~=(lhs: (String, OperationErrorCode, String), rhs: (String, Int, String?)) -> Bool {
    return lhs.0 ~= rhs.0 && lhs.1.rawValue ~= rhs.1 && lhs.2 == rhs.2
}
