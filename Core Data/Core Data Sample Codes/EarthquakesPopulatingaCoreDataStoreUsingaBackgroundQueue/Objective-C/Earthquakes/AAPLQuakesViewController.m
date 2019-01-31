/*
 Copyright (C) 2017 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 View controller to manage a a table view that displays a collection of quakes.
 
  When requested (by clicking the Fetch Quakes button), the controller creates an asynchronous NSURLSession task to retrieve JSON data about earthquakes. Earthquake data are compared with any existing managed objects to determine whether there are new quakes. New managed objects are created to represent new data, and saved to the persistent store on a private queue.
 */

#import "AAPLQuakesViewController.h"
#import "AAPLQuake.h"

@interface AAPLQuakesViewController () <NSTableViewDataSource, NSTableViewDelegate, NSFetchedResultsControllerDelegate>

@property (weak) IBOutlet NSTableView *tableView;
@property (weak) IBOutlet NSButton *fetchQuakesButton;
@property (weak) IBOutlet NSProgressIndicator *progressIndicator;

@property (nonatomic) NSPersistentContainer *persistentContainer;
@property (nonatomic) NSFetchedResultsController<AAPLQuake *> *fetchedResultsController;

@end

NSString *const EntityNameQuake = @"Quake";

NSString *const ColumnIdentifierPlace = @"placeName";
NSString *const ColumnIdentifierTime = @"time";
NSString *const ColumnIdentifierMagnitude = @"magnitude";

NSString *EARTHQUAKES_ERROR_DOMAIN = @"EARTHQUAKES_ERROR_DOMAIN";


@implementation AAPLQuakesViewController

#pragma mark - Core Data stack and Fetched results controller


- (NSPersistentContainer *)persistentContainer
{
    @synchronized (self) {
        
        if (_persistentContainer != nil) {
            return _persistentContainer;
        }
        
        _persistentContainer = [[NSPersistentContainer alloc] initWithName:@"Earthquakes"];
        
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        // Typical reasons for an error here include:
        // * The parent directory does not exist, cannot be created, or disallows writing.
        // * The persistent store is not accessible, due to permissions or data protection when the device is locked.
        // * The device is out of space.
        // * The store could not be migrated to the current model version.
        // Check the error message to determine what the actual problem was.
        [_persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error){
            if (error != nil) {
                NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                abort();
            }
        }];
        
        _persistentContainer.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
        _persistentContainer.viewContext.undoManager = nil; // We don't need undo so set it to nil.
        _persistentContainer.viewContext.shouldDeleteInaccessibleFaults = true;
        
        // Merge the changes from other contexts automatically.
        // You can also choose to merge the changes by observing NSManagedObjectContextDidSave
        // notification and calling mergeChanges(fromContextDidSave notification: Notification)
        //
        _persistentContainer.viewContext.automaticallyMergesChangesFromParent = true;
    }
    return _persistentContainer;
}

- (NSFetchedResultsController<AAPLQuake *> *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest<AAPLQuake *> *fetchRequest = [[NSFetchRequest<AAPLQuake *> alloc] initWithEntityName: EntityNameQuake];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:ColumnIdentifierTime ascending:NO];
    
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController<AAPLQuake *> *aFetchedResultsController;
    aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                    managedObjectContext:self.persistentContainer.viewContext
                                                                      sectionNameKeyPath:nil cacheName:nil];
    aFetchedResultsController.delegate = self;
    
    // Replace this implementation with code to handle the error appropriately.
    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application,
    // although it may be useful during development.
    NSError *error = nil;
    if (![aFetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
    }
    
    _fetchedResultsController = aFetchedResultsController;
    return _fetchedResultsController;
}

#pragma mark - Core Data Batch importing

- (IBAction)fetchQuakes:(id)sender {
    // Ensure the button can't be pressed again until the fetch is complete.
    self.fetchQuakesButton.enabled = NO;
    self.progressIndicator.hidden = NO;
    [self.progressIndicator startAnimation:nil];

    // Create an NSURLSession and then session task to contact the earthquake server and retrieve JSON data.
    // Because this server is out of our control and does not offer a secure communication channel,
    // we'll use the http version of the URL and add "earthquake.usgs.gov" to the "NSExceptionDomains"
    // value in the apps's info.plist. When you commmunicate with your own servers, or when the services you
    // use offer a secure communication option, you should always prefer to use HTTPS.
    NSURL *jsonURL = [NSURL URLWithString:@"http://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_month.geojson"];

    NSURLSession *session = [NSURLSession sessionWithConfiguration: [NSURLSessionConfiguration ephemeralSessionConfiguration]];

    NSURLSessionDataTask *task = [session dataTaskWithURL:jsonURL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {

        if (!data) {
            [[NSOperationQueue mainQueue] addOperationWithBlock: ^{
                NSLog(@"Error connecting: %@", [error localizedDescription]);
                NSString *description = NSLocalizedString(@"Could not get data from the remote server", @"Failed to connect to server");
                NSDictionary *dict = @{NSLocalizedDescriptionKey:description, NSUnderlyingErrorKey:error};
                NSError *connectionError = [NSError errorWithDomain:EARTHQUAKES_ERROR_DOMAIN code:101 userInfo:dict];
                [NSApp presentError:connectionError];
                self.fetchQuakesButton.enabled = YES;
                [self.progressIndicator stopAnimation:nil];
                self.progressIndicator.hidden = YES;

            }];
            return;
        }

        NSError *anyError = nil;
        
        NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&anyError];
        if (!jsonDictionary) {
            [[NSOperationQueue mainQueue] addOperationWithBlock: ^{
                NSLog(@"Error creating JSON dictionary: %@", [anyError localizedDescription]);
                NSString *description = NSLocalizedString(@"Could not analyze earthquake data", @"Failed to unpack JSON");
                NSDictionary *dict = @{NSLocalizedDescriptionKey:description, NSUnderlyingErrorKey:anyError};
                NSError *jsonDataError = [NSError errorWithDomain:EARTHQUAKES_ERROR_DOMAIN code:102 userInfo:dict];
                [NSApp presentError:jsonDataError];
                self.fetchQuakesButton.enabled = YES;
                [self.progressIndicator stopAnimation:nil];
                self.progressIndicator.hidden = YES;

            }];
            return;
        }
        
        if (! [self importFromJsonDictionary:jsonDictionary error:&anyError]) {
            [[NSOperationQueue mainQueue] addOperationWithBlock: ^{
                NSLog(@"Error importing JSON dictionary: %@", [anyError localizedDescription]);
                NSString *description = NSLocalizedString(@"Could not import earthquake data", @"Failed to importing JSON dictionary");
                NSDictionary *dict = @{NSLocalizedDescriptionKey:description, NSUnderlyingErrorKey:anyError};
                NSError *coreDataError = [NSError errorWithDomain:EARTHQUAKES_ERROR_DOMAIN code:102 userInfo:dict];
                [NSApp presentError:coreDataError];
                self.fetchQuakesButton.enabled = YES;
                [self.progressIndicator stopAnimation:nil];
                self.progressIndicator.hidden = YES;

            }];
            return;
        };
        
        // Bounce back to the main queue to reload the table view and reenable the fetch button.
        [[NSOperationQueue mainQueue] addOperationWithBlock: ^{
            self.fetchQuakesButton.enabled = YES;
            [self.progressIndicator stopAnimation:nil];
            self.progressIndicator.hidden = YES;
            [self.tableView reloadData];
        }];
    }];

    [task resume];
}

- (BOOL)importFromJsonDictionary:(NSDictionary *)jsonDictionary error:(NSError * __autoreleasing *)error {
    
    // Create a context on a private queue to fetch existing quakes to compare with incoming data and create new quakes as required.
    NSManagedObjectContext *taskContext = self.persistentContainer.newBackgroundContext;
    if (!taskContext) {
        return false;
    }
    
    // Sort the dictionaries by code; this way they can be compared in parallel with existing quakes.
    NSArray *featuresArray = jsonDictionary[@"features"];
    NSArray *sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"properties.code" ascending:YES]];
    featuresArray = [featuresArray sortedArrayUsingDescriptors:sortDescriptors];
    
    // To avoid a high memory footprint, process records in batches.
    const NSUInteger batchSize = 256;

    NSUInteger totalFeatureCount = featuresArray.count;
    NSUInteger numBatches = totalFeatureCount / batchSize;
    numBatches += totalFeatureCount % batchSize > 0 ? 1 : 0;
    
    for (NSUInteger batchNumber = 0; batchNumber < numBatches; batchNumber++) {
        
        NSInteger rangeStart = batchNumber * batchSize;
        NSInteger rangeLength = MIN(batchSize, totalFeatureCount - batchNumber * batchSize);
        
        NSRange range = NSMakeRange(rangeStart, rangeLength);
        NSArray *featuresBatchArray = [featuresArray subarrayWithRange:range];
        
        if (![self importFromFeaturesArray:featuresBatchArray usingContext:taskContext error:error]) {
            return false;
        }
    }
    return true;
}

- (BOOL)importFromFeaturesArray:(NSArray *)featuresArray usingContext:(NSManagedObjectContext *)taskContext
                      error:(NSError * __autoreleasing *)error {
    
    [taskContext performBlockAndWait:^{
        
        // Create a request to fetch existing quakes with the same codes as those in the JSON data.
        // Existing quakes will be updated with new data; if there isn't a match, then create a new quake to represent the event.
        NSFetchRequest *matchingQuakeRequest = [NSFetchRequest fetchRequestWithEntityName: EntityNameQuake];
        NSArray *codes = [featuresArray valueForKeyPath:@"properties.code"];
        matchingQuakeRequest.predicate = [NSPredicate predicateWithFormat:@"code in %@" argumentArray:@[codes]];
        
        NSBatchDeleteRequest *batchDeleteRequest = [[NSBatchDeleteRequest alloc] initWithFetchRequest:matchingQuakeRequest];
        batchDeleteRequest.resultType = NSManagedObjectIDResultType;
        
        NSBatchDeleteResult *batchDeleteResult = (NSBatchDeleteResult *)[taskContext executeRequest:batchDeleteRequest error:error];

        // Merge the changes to viewContext and trigger UI update.
        if (*error == nil) {
            NSArray * deletedObjectIDs = (NSArray *)batchDeleteResult.result;
            if (deletedObjectIDs.count > 0) {
                [NSManagedObjectContext mergeChangesFromRemoteContextSave: @{NSDeletedObjectsKey: deletedObjectIDs}
                                                             intoContexts: @[self.persistentContainer.viewContext]];
            }
        }
        else {
            NSLog(@"Unresolved error %@, %@", *error, (*error).userInfo);
        }
        
        for (NSDictionary *result in featuresArray) {
            // For each feature in turn, retrieve the properties for the quake and create a new quake or update an existing one accordingly.
            NSDictionary * quakeDictionary = result[@"properties"];
            AAPLQuake *quake = [NSEntityDescription insertNewObjectForEntityForName: EntityNameQuake inManagedObjectContext:taskContext];
            [quake updateFromDictionary:quakeDictionary];
        }
        
        if ([taskContext hasChanges]) {
            
            if (![taskContext save:error]) {
                return;
            }
            [taskContext reset];
        }
    }];
    
    return *error ? false : true;
}

#pragma mark - NSTableViewDataSource

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.fetchedResultsController.fetchedObjects.count;
}

#pragma mark - NSTableViewDelegate

-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSString *identifier = [tableColumn identifier];
    
    NSTableCellView *cellView = [tableView makeViewWithIdentifier:identifier owner:self];

    AAPLQuake *quake = self.fetchedResultsController.fetchedObjects[row];

    if ([identifier isEqualToString:ColumnIdentifierPlace]) {
        cellView.textField.stringValue = quake.placeName;
    }
    else if ([identifier isEqualToString:ColumnIdentifierTime]) {
        cellView.textField.objectValue = quake.time;
    }
    else if ([identifier isEqualToString:ColumnIdentifierMagnitude]) {
        cellView.textField.objectValue = @(quake.magnitude);
    }

    return cellView;
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView reloadData];
}

@end

