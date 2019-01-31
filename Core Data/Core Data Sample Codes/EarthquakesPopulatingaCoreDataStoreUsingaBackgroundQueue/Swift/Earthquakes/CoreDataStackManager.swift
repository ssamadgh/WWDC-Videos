/*
    Copyright (C) 2017 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    Singleton controller to manage the main Core Data stack for the application. It vends a persistent store coordinator, the managed object model, and a URL for the persistent store.
*/

import Cocoa

class CoreDataStackManager {
    // MARK: Properties
    
    static let sharedManager = CoreDataStackManager()
    static let applicationDocumentsDirectoryName = "com.example.apple-samplecode.Earthquakes"
    static let mainStoreFileName = "Earthquakes.storedata"
    static let errorDomain = "CoreDataStackManager"

    private init() {} // Prevent clients from creating another instance.
    
    // The managed object model for the application.
    //
    lazy var managedObjectModel: NSManagedObjectModel = {

        // This property is not optional. It is a fatal error for the application
        // not to be able to find and load its model.
        //
        let modelURL = Bundle.main.url(forResource: "Earthquakes", withExtension: "momd")!

        return NSManagedObjectModel(contentsOf: modelURL)!
    }()

    // Primary persistent store coordinator for the application.
    //
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {

        // This implementation creates and return a coordinator, having added the
        // store for the application to it. (The directory for the store is created, if necessary.)
        //
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        
        do {
            let options = [
                NSMigratePersistentStoresAutomaticallyOption: true,
                NSInferMappingModelAutomaticallyOption: true
            ]

            try persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: self.storeURL, options: options)
        }
        catch {
            fatalError("Could not add the persistent store: \(error).")
        }

        return persistentStoreCoordinator
    }()
    
    
    lazy var mainQueueContext: NSManagedObjectContext = {
        
        let moc = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        moc.persistentStoreCoordinator = self.persistentStoreCoordinator
        
        // Avoid using default merge policy in multi-threading environment:
        // when we delete (and save) a record in one context,
        // and try to save edits on the same record in the other context before merging the changes,
        // an exception will be thrown because Core Data by default uses NSErrorMergePolicy.
        // Setting a reasonable mergePolicy is a good practice to avoid that kind of exception.
        
        moc.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        // In macOS, a context provides an undo manager by default
        // Disable it for performance benefit
        //
        moc.undoManager = nil
        
        return moc
    }()

    
    
    /// The directory the application uses to store the Core Data store file.
    //
    lazy var applicationSupportDirectory: URL = {
        
        let fileManager = FileManager.default

        // Use the app support directory directly if URLByAppendingPathComponent failed.
        //
        let supportDirectory = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).last!
        let applicationSupportDirectory = supportDirectory.appendingPathComponent(applicationDocumentsDirectoryName)
        
        do {
            let properties = try (applicationSupportDirectory as NSURL).resourceValues(forKeys: [URLResourceKey.isDirectoryKey])
            if let isDirectory = properties[URLResourceKey.isDirectoryKey] as? Bool, isDirectory == false {
                
                let description = NSLocalizedString("Could not access the application data folder.", comment: "Failed to initialize applicationSupportDirectory.")
                
                let reason = NSLocalizedString("Found a file in its place.", comment: "Failed to initialize applicationSupportDirectory.")
                
                throw NSError(domain: errorDomain, code: 201, userInfo: [
                    NSLocalizedDescriptionKey: description,
                    NSLocalizedFailureReasonErrorKey: reason
                ])
            }
        }
        catch let error as NSError where error.code != NSFileReadNoSuchFileError {
            fatalError("Error occured: \(error).")
        }
        catch {
            let path = applicationSupportDirectory.path

            do {
                try fileManager.createDirectory(atPath: path, withIntermediateDirectories:true, attributes:nil)
            }
            catch {
                fatalError("Could not create application documents directory at \(path).")
            }
        }
        
        return applicationSupportDirectory
    }()
    
    // URL for the main Core Data store file.
    //
    lazy var storeURL: URL = {
        return self.applicationSupportDirectory.appendingPathComponent(mainStoreFileName)
    }()
    
    
    // Creates a new Core Data stack and returns a managed object context associated with a private queue.
    //
    func newPrivateQueueContextWithNewPSC() throws -> NSManagedObjectContext {
    
        // Stack uses the same store and model, but a new persistent store coordinator and context.
        //
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: CoreDataStackManager.sharedManager.managedObjectModel)
        
        // Attempting to add a persistent store may yield an error--pass it out of
        // the function for the caller to deal with.
        //
        try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: CoreDataStackManager.sharedManager.storeURL, options: nil)
        
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
    
        context.performAndWait() {
        
            context.persistentStoreCoordinator = coordinator
        
            // Avoid using default merge policy in multi-threading environment:
            // when we delete (and save) a record in one context,
            // and try to save edits on the same record in the other context before merging the changes,
            // an exception will be thrown because Core Data by default uses NSErrorMergePolicy.
            // Setting a reasonable mergePolicy is a good practice to avoid that kind of exception.
            //
            context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            
            // In macOS, a context provides an undo manager by default
            // Disable it for performance benefit
            //
            context.undoManager = nil
        }
    
        return context
    }
}
