/*
     File: APLViewController.m
 Abstract: View controller for displaying the earthquake list; initiates the download of the XML data and parses the Earthquake objects at view load time.
  Version: 1.1
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2013 Apple Inc. All Rights Reserved.
 
 */

#import "APLViewController.h"
#import "APLParseOperation.h"

#import "Earthquake.h"
#import "APLEarthquakeTableViewCell.h"

// This framework is imported so we can use the kCFURLErrorNotConnectedToInternet error code.
#import <CFNetwork/CFNetwork.h>


@interface APLViewController () <UIActionSheetDelegate, NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong) NSManagedObjectModel *managedObjectModel;

@property (nonatomic, strong) UIBarButtonItem *activityIndicator;

@property (nonatomic) NSMutableArray *earthquakeList;
@property (nonatomic) NSURLConnection *earthquakeFeedConnection;
@property (nonatomic) NSMutableData *earthquakeData;    // The data returned from the NSURLConnection.
@property (nonatomic) NSOperationQueue *parseQueue;     // The queue that manages our NSOperation for parsing earthquake data.

@end

#pragma mark -

@implementation APLViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.earthquakeList = [NSMutableArray array];
    
    /*
     Use NSURLConnection to asynchronously download the data. This means the main thread will not be blocked - the application will remain responsive to the user.
     
     IMPORTANT! The main thread of the application should never be blocked!
     Also, avoid synchronous network access on any thread.
     */
    static NSString *feedURLString = @"http://earthquake.usgs.gov/eqcenter/catalogs/7day-M2.5.xml";
    NSURLRequest *earthquakeURLRequest =
    [NSURLRequest requestWithURL:[NSURL URLWithString:feedURLString]];
    self.earthquakeFeedConnection = [[NSURLConnection alloc] initWithRequest:earthquakeURLRequest delegate:self];
    
    /*
     Test the validity of the connection object. The most likely reason for the connection object to be nil is a malformed URL, which is a programmatic error easily detected during development. If the URL is more dynamic, then you should implement a more flexible validation technique, and be able to both recover from errors and communicate problems to the user in an unobtrusive manner.
     */
    NSAssert(self.earthquakeFeedConnection != nil, @"Failure to create URL connection.");
    
    /*
     Start the status bar network activity indicator. We'll turn it off when the connection finishes or experiences an error.
     */
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    self.parseQueue = [NSOperationQueue new];
    
    // observe the keypath change to get notified of the end of the parser operation to hid the activity indicator
    [self.parseQueue addObserver:self forKeyPath:@"operationCount" options:0 context:NULL];
    
    // observe for any errors that come from our parser
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(earthquakesError:) name:kEarthquakesErrorNotificationName object:nil];
    
    // add our activity indicator to the navigation bar
	UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [activityIndicator startAnimating];
	_activityIndicator = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
	self.navigationItem.rightBarButtonItem = self.activityIndicator;
}

- (void)dealloc {
    
    [_earthquakeFeedConnection cancel];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - NSURLConnectionDelegate

/*
 The following are delegate methods for NSURLConnection. Similar to callback functions, this is how the connection object, which is working in the background, can asynchronously communicate back to its delegate on the thread from which it was started - in this case, the main thread.
 */
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    /*
     Check for HTTP status code for proxy authentication failures anything in the 200 to 299 range is considered successful, also make sure the MIMEType is correct.
     */
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    if ((([httpResponse statusCode]/100) == 2) && [[response MIMEType] isEqual:@"application/atom+xml"]) {
        self.earthquakeData = [NSMutableData data];
    }
    else {
        NSString * errorString = NSLocalizedString(@"HTTP Error", @"Error message displayed when receving a connection error.");
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey : errorString};
        NSError *error = [NSError errorWithDomain:@"HTTP" code:[httpResponse statusCode] userInfo:userInfo];
        [self handleError:error];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
    [self.earthquakeData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    if ([error code] == kCFURLErrorNotConnectedToInternet) {
        // If we can identify the error, we present a suitable message to the user.
        NSString * errorString = NSLocalizedString(@"No Connection Error", @"Error message displayed when not connected to the Internet.");
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey : errorString};
        NSError *noConnectionError = [NSError errorWithDomain:NSCocoaErrorDomain code:kCFURLErrorNotConnectedToInternet userInfo:userInfo];
        [self handleError:noConnectionError];
    }
    else {
        // Otherwise handle the error generically.
        [self handleError:error];
    }
    
    self.earthquakeFeedConnection = nil;
    
    // hide activity indicator when networking failed
    [self hideActivityIndicator];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    self.earthquakeFeedConnection = nil;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    /*
     Spawn an NSOperation to parse the earthquake data so that the UI is not blocked while the application parses the XML data.
     IMPORTANT! - Don't access or affect UIKit objects on secondary threads.
     */
    
    APLParseOperation *parseOperation = [[APLParseOperation alloc] initWithData:self.earthquakeData
                                                                      sharedPSC:self.persistentStoreCoordinator];
    [self.parseQueue addOperation:parseOperation];
    
    /*
     The NSOperation object  maintains a strong reference to the earthquakeData until it has finished executing, so we no longer need a reference to earthquakeData in the main thread.
     */
    self.earthquakeData = nil;
}

/**
 Handle errors in the download by showing an alert to the user. This is a very simple way of handling the error, partly because this application does not have any offline functionality for the user. Most real applications should handle the error in a less obtrusive way and provide offline functionality to the user.
 */
- (void)handleError:(NSError *)error {
    
    NSString *errorMessage = [error localizedDescription];
    NSString *alertTitle = NSLocalizedString(@"Error Title", @"Title for alert displayed when download or parse error occurs.");
    NSString *okTitle = NSLocalizedString(@"OK ", @"OK Title for alert displayed when download or parse error occurs.");
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:alertTitle message:errorMessage delegate:nil cancelButtonTitle:okTitle otherButtonTitles:nil];
    [alertView show];
}

/**
 Our NSNotification callback from the running NSOperation when a parsing error has occurred
 */
- (void)earthquakesError:(NSNotification *)notif {
    
    assert([NSThread isMainThread]);
    if (notif.name == kEarthquakesErrorNotificationName) {
        [self handleError:[[notif userInfo] valueForKey:kEarthquakesMessageErrorKey]];
    }
}


#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSInteger numberOfRows = 0;
	
    if ([[self.fetchedResultsController sections] count] > 0) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
        numberOfRows = [sectionInfo numberOfObjects];
    }
    
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *kEarthquakeCellID = @"EarthquakeCellID";
  	APLEarthquakeTableViewCell *cell = (APLEarthquakeTableViewCell *)[tableView dequeueReusableCellWithIdentifier:kEarthquakeCellID];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    Earthquake *earthquake = (Earthquake *)[self.fetchedResultsController objectAtIndexPath:indexPath];
    [cell configureWithEarthquake:earthquake];
    
	return cell;
}

// called after fetched results controller received a content change notification
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    
    [self.tableView reloadData];
}

- (NSFetchedResultsController *)fetchedResultsController {
    
    // Set up the fetched results controller if needed.
    if (_fetchedResultsController == nil) {
        // Create the fetch request for the entity.
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        // Edit the entity name as appropriate.
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Earthquake"
                                                  inManagedObjectContext:self.managedObjectContext];
        [fetchRequest setEntity:entity];
        
        // Edit the sort key as appropriate.
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
        
        [fetchRequest setSortDescriptors:sortDescriptors];
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        NSFetchedResultsController *aFetchedResultsController =
        [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                            managedObjectContext:self.managedObjectContext
                                              sectionNameKeyPath:nil
                                                       cacheName:nil];
        self.fetchedResultsController = aFetchedResultsController;
        
        self.fetchedResultsController.delegate = self;
        
        NSError *error = nil;
        
        if (![self.fetchedResultsController performFetch:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate.
            // You should not use this function in a shipping application, although it may be useful
            // during development. If it is not possible to recover from the error, display an alert
            // panel that instructs the user to quit the application by pressing the Home button.
            //
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        
    }
	
	return _fetchedResultsController;
}


#pragma mark - Core Data stack

// Returns the path to the application's documents directory.
- (NSString *)applicationDocumentsDirectory {
    
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
//
- (NSManagedObjectContext *)managedObjectContext {
	
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
	
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [NSManagedObjectContext new];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    
    // observe the ParseOperation's save operation with its managed object context
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mergeChanges:)
                                                 name:NSManagedObjectContextDidSaveNotification
                                               object:nil];
    
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
//
- (NSManagedObjectModel *)managedObjectModel {
	
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Earthquakes" withExtension:@"mom"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it
//
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
	
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // find the earthquake data in our Documents folder
    NSString *storePath = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:@"Earthquakes.sqlite"];
    NSURL *storeUrl = [NSURL fileURLWithPath:storePath];
    
    NSError *error;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate.
        // You should not use this function in a shipping application, although it may be useful
        // during development. If it is not possible to recover from the error, display an alert
        // panel that instructs the user to quit the application by pressing the Home button.
        //
        
        // Typical reasons for an error here include:
        // The persistent store is not accessible
        // The schema for the persistent store is incompatible with current managed object model
        // Check the error message to determine what the actual problem was.
        //
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
    }
    
    return _persistentStoreCoordinator;
}

// merge changes to main context,fetchedRequestController will automatically monitor the changes and update tableview.
- (void)updateMainContext:(NSNotification *)notification {
    
    assert([NSThread isMainThread]);
    [self.managedObjectContext mergeChangesFromContextDidSaveNotification:notification];
}

// this is called via observing "NSManagedObjectContextDidSaveNotification" from our APLParseOperation
- (void)mergeChanges:(NSNotification *)notification {
    
    if (notification.object != self.managedObjectContext) {
        [self performSelectorOnMainThread:@selector(updateMainContext:) withObject:notification waitUntilDone:NO];
    }
}

// stop the animation of activityIndicator and hide it
- (void)hideActivityIndicator {
    
    // we are done processing earthquakes, stop our activity indicator
    UIActivityIndicatorView *indicatorView = (UIActivityIndicatorView *)self.activityIndicator.customView;
    [indicatorView stopAnimating];
    self.navigationItem.rightBarButtonItem = nil;
}

// observe the queue's operationCount, stop activity indicator if there is no operatation ongoing.
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == self.parseQueue && [keyPath isEqualToString:@"operationCount"]) {
        
        if (self.parseQueue.operationCount == 0) {
            [self performSelectorOnMainThread:@selector(hideActivityIndicator) withObject:nil waitUntilDone:NO];
        }
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end

