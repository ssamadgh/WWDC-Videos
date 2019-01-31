/*
Copyright (C) 2017 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
A `NSViewController` subclass to manage a table view that displays a collection of quakes.

When requested (by clicking the Fetch Quakes button), the controller creates an asynchronous `NSURLSession` task to retrieve JSON data about earthquakes. Earthquake data are compared with any existing managed objects to determine whether there are new quakes. New managed objects are created to represent new data, and saved to the persistent store on a private queue.
*/

import Cocoa
import CoreData

// An enumeration to specify codes for error conditions.
//
private enum QuakeViewControllerErrorCode: Int {
    case serverConnectionFailed = 101
    case unpackingJSONFailed = 102
    case processingQuakeDataFailed = 103
    case fetchRequestFailed = 104
}


class QuakesViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate, NSFetchedResultsControllerDelegate {
    // MARK: Types
    
    // An enumeration to specify the names of earthquake properties that should
    // be displayed in the table view.
    //
    fileprivate enum QuakeDisplayProperty: String {
        case place      = "placeName"
        case time       = "time"
        case magnitude  = "magnitude"
    }
    
    // MARK: Properties
    //
    @IBOutlet fileprivate weak var tableView: NSTableView!
    @IBOutlet fileprivate weak var fetchQuakesButton: NSButton!
    @IBOutlet fileprivate weak var progressIndicator: NSProgressIndicator!
    
    lazy var persistentContainer: NSPersistentContainer = {

        let container = NSPersistentContainer(name: "Earthquakes")
        
        // fatalError() causes the application to generate a crash log and terminate.
        // You should not use this function in a shipping application.
        //
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            guard let error = error as NSError? else {return}
            fatalError("Unresolved error \(error), \(error.userInfo)")
        })
        
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.undoManager = nil // We don't need undo so set it to nil.
        container.viewContext.shouldDeleteInaccessibleFaults = true

        // Merge the changes from other contexts automatically.
        // You can also choose to merge the changes by observing NSManagedObjectContextDidSave
        // notification and calling mergeChanges(fromContextDidSave notification: Notification)
        //
        container.viewContext.automaticallyMergesChangesFromParent = true

        return container
    }()

    // NSFetchedResultsController has been available on macOS since 10.12.
    //
    lazy var fetchedResultsController: NSFetchedResultsController<Quake> = {
    
        let fetchRequest = NSFetchRequest<Quake>(entityName:"Quake")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: QuakeDisplayProperty.time.rawValue, ascending:false)]
        
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                    managedObjectContext: self.persistentContainer.viewContext,
                                                    sectionNameKeyPath: nil,
                                                    cacheName: nil)
        controller.delegate = self
        
        do {
            try controller.performFetch()
        }
        catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        return controller
    }()

    // MARK: Core Data Batching
    //
    @IBAction func fetchQuakes(_ sender: AnyObject) {
        
        // Ensure the button can't be pressed again until the fetch is complete.
        //
        fetchQuakesButton.isEnabled = false
        progressIndicator.isHidden = false
        progressIndicator.startAnimation(nil)
        
        // Create an `NSURLSession` and then session task to contact the earthquake
        // server and retrieve JSON data. Because this server is out of our control
        // and does not offer a secure communication channel, we'll use the http
        // version of the URL and add "earthquake.usgs.gov" to the "NSExceptionDomains"
        // value in the apps's info.plist. When you commmunicate with your own
        // servers, or when the services you use offer a secure communication
        // option, you should always prefer to use HTTPS.
        //
        let jsonURL = URL(string: "http://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_month.geojson")!
        
        let sessionConfiguration = URLSessionConfiguration.ephemeral
        let session = URLSession(configuration: sessionConfiguration)
        
        let task = session.dataTask(with: jsonURL, completionHandler: { dataOptional, response, error in
            // Enable the button and reload the table view when the operation finishes.
            //
            defer {
                DispatchQueue.main.async {
                    self.fetchQuakesButton.isEnabled = true
                    self.progressIndicator.stopAnimation(nil)
                    self.progressIndicator.isHidden = true
                    self.tableView.reloadData()
                }
            }
            
            // If we don't get data back, alert the user.
            //
            guard let data = dataOptional else {
                let description = NSLocalizedString("Could not get data from the remote server", comment: "Failed to connect to server")
                self.presentError(description, code: .serverConnectionFailed, underlyingError: error)
                return
            }
            
            // If we get data but can't unpack it as JSON, alert the user.
            //
            let jsonDictionary: [AnyHashable: Any]
            
            do {
                jsonDictionary = try JSONSerialization.jsonObject(with: data, options: []) as! [AnyHashable: Any]
            }
            catch {
                let description = NSLocalizedString("Could not analyze earthquake data", comment: "Failed to unpack JSON")
                self.presentError(description, code: .unpackingJSONFailed, underlyingError: error)
                return
            }
            
            // If we can't process the data and save it, alert the user.
            //
            do {
                try self.importFromJsonDictionary(jsonDictionary)
            }
            catch {
                let description = NSLocalizedString("Could not process earthquake data", comment: "Could not process updates")
                self.presentError(description, code: .processingQuakeDataFailed, underlyingError: error)
                return
            }
        }) 
        
        // If the task is created, start it by calling resume.
        //
        task.resume()
    }
    
    // MARK: Convenience Methods
    //
    fileprivate func presentError(_ description: String, code: QuakeViewControllerErrorCode, underlyingError error: Error?) {

        var userInfo: [String: AnyObject] = [
            NSLocalizedDescriptionKey: description as AnyObject
        ]

        if let error = error as NSError? {
            userInfo[NSUnderlyingErrorKey] = error
        }
        
        let creationError = NSError(domain: EarthQuakesErrorDomain, code: code.rawValue, userInfo: userInfo)
        
        DispatchQueue.main.async {
            NSApp.presentError(creationError)
        }
    }
    
    fileprivate func importFromJsonDictionary(_ jsonDictionary: [AnyHashable: Any]) throws {
        // Any errors enountered in this function are passed back to the caller.
        
        // Create a context on a private queue to:
        // - Fetch existing quakes to compare with incoming data.
        // - Create new quakes as required.
        //
        let taskContext = persistentContainer.newBackgroundContext()
        taskContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        taskContext.undoManager = nil // We don't need undo so set it to nil.
        
        // Sort the dictionaries by code so they can be compared in parallel with
        // existing quakes.
        //
        let quakeDictionaries = jsonDictionary["features"] as! [[String: AnyObject]]
        
        let sortedQuakeDictionaries = quakeDictionaries.sorted { lhs, rhs in
            let lhsResult = lhs["properties"]?["code"] as! String
            let rhsResult = rhs["properties"]?["code"] as! String
            return lhsResult < rhsResult
        }
        
        // To avoid a high memory footprint, process records in batches.
        //
        let batchSize = 256
        let count = sortedQuakeDictionaries.count
        
        var numBatches = count / batchSize
        numBatches += count % batchSize > 0 ? 1 : 0
        
        for batchNumber in 0 ..< numBatches {
            let batchStart = batchNumber * batchSize
            let batchEnd = batchStart + min(batchSize, count - batchNumber * batchSize)
            let range = batchStart..<batchEnd
            
            let quakesBatch = Array(sortedQuakeDictionaries[range])
            
            if !importFromFeaturesArray(quakesBatch, taskContext: taskContext) {
                return;
            }
        }
    }
    
    fileprivate func importFromFeaturesArray(_ featuresArray: [[String: AnyObject]], taskContext: NSManagedObjectContext) ->Bool {
        
        var success = false
        taskContext.performAndWait() {
            // Fetch the existing records with the same code, then remove them and create new records with the latest data
            // to replace them.
            //
            let matchingQuakeRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Quake")
            
            let codes: [String] = featuresArray.map { dictionary in
                return dictionary["properties"]?["code"] as! String
            }
            matchingQuakeRequest.predicate = NSPredicate(format: "code in %@", argumentArray: [codes])
            
            // Create batch delete request and set the result type to .resultTypeObjectIDs so that we can merge the changes
            //
            let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: matchingQuakeRequest)
            batchDeleteRequest.resultType = .resultTypeObjectIDs
            
            // Execute the request to de batch delete and merge the changes to viewContext, which triggers the UI update
            //
            do {
                let batchDeleteResult = try taskContext.execute(batchDeleteRequest) as? NSBatchDeleteResult
                
                if let deletedObjectIDs = batchDeleteResult?.result as? [NSManagedObjectID] {
                    NSManagedObjectContext.mergeChanges(fromRemoteContextSave: [NSDeletedObjectsKey : deletedObjectIDs],
                                                        into: [self.persistentContainer.viewContext])
                }
            }
            catch {
                print("Error: \(error)\nCould not batch delete existing records.")
            }
            
            // Create new records.
            //
            for quakeDictionary in featuresArray {
                let quake = NSEntityDescription.insertNewObject(forEntityName: "Quake", into: taskContext) as! Quake
                
                // Set the attribute values the quake object.
                // If the data is not valid, delete the object and continue to process the next one.
                //
                do {
                    try quake.update(with: quakeDictionary)
                }
                catch {
                    taskContext.delete(quake)
                }
            }
            // Save all the changes just made and reset the taskContext to free the cache.
            //
            if taskContext.hasChanges {
                do {
                    try taskContext.save()
                }
                catch {
                    print("Error: \(error)\nCould not save Core Data context.")
                    return
                }
                taskContext.reset()
            }
            success = true
        }
        return success
    }

    // MARK: NSTableViewDataSource
    //
    func numberOfRows(in tableView: NSTableView) -> Int {
        return fetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    // MARK: NSTableViewDelegate
    //
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {

        let identifier = tableColumn!.identifier
        guard let propertyEnum = QuakeDisplayProperty(rawValue: identifier) else {return nil}
        
        let cellView = tableView.make(withIdentifier: identifier, owner: self) as! NSTableCellView
        let textField = cellView.textField!
        
        if let quake = fetchedResultsController.fetchedObjects?[row] {
            
            switch propertyEnum {
            case .place:
                textField.stringValue = quake.placeName
                
            case .time:
                textField.objectValue = quake.time
                
            case .magnitude:
                textField.objectValue = quake.magnitude
            }
        }
        return cellView
    }
    
    // MARK: NSFetchedResultsControllerDelegate, available on macOS 10.12+
    //
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.reloadData()
    }
}
