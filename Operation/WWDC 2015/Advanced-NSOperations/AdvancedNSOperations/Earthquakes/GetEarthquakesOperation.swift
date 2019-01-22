/*
Copyright (C) 2015 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
This file sets up the operations to download and parse earthquake data. It will also decide to display an error message, if appropriate.
*/

import Foundation
import CoreData

/// A composite `Operation` to both download and parse earthquake data.
class GetEarthquakesOperation: GroupOperation {
    // MARK: Properties
    
    let downloadOperation: DownloadEarthquakesOperation
    let parseOperation: ParseEarthquakesOperation
   
    fileprivate var hasProducedAlert = false
    
    /**
        - parameter context: The `NSManagedObjectContext` into which the parsed
                             Earthquakes will be imported.

        - parameter completionHandler: The handler to call after downloading and
                                       parsing are complete. This handler will be
                                       invoked on an arbitrary queue.
    */
    init(context: NSManagedObjectContext, completionHandler: @escaping () -> Void) {
        let cachesFolder = try! FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)

        let cacheFile = cachesFolder.appendingPathComponent("earthquakes.json")
        
        /*
            This operation is made of three child operations:
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
            We only want to show the first error, since subsequent errors might
            be caused by the first.
        */
        if hasProducedAlert { return }
        
        let alert = AlertOperation()
        
        let errorReason = (error.domain, error.code, error.userInfo[OperationConditionKey] as? String)
        
        // These are examples of errors for which we might choose to display an error to the user
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
                alert.message = "Cannot download earthquake data. Try again later."

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
