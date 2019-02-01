/*
 Copyright (C) 2017 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 Table view controller to manage an editable table view that displays a list of recipes.
   Recipes are displayed in a custom table view cell.
 */

#import "RecipeListTableViewController.h"
#import "RecipeDetailViewController.h"
#import "Recipe.h"
#import "RecipeTableViewCell.h"

@interface RecipeListTableViewController () <RecipeAddDelegate, NSFetchedResultsControllerDelegate>
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@end

@implementation RecipeListTableViewController

// Segue ID when "+" button is tapped.
static NSString *kShowRecipeSegueID = @"showRecipe";

// Segue ID when "Add Ingredient" cell is tapped.
static NSString *kAddRecipeSegueID = @"addRecipe";


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    // Add the table's edit button to the left side of the nav bar.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;

    // Set the table view's row height.
    self.tableView.rowHeight = 44.0;
	
    NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
		/*
		 Replace this implementation with code to handle the error appropriately.
		 
		 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
		 */
		NSLog(@"Unresolved error %@, %@", error, error.userInfo);
		abort();
	}
}


#pragma mark - Recipe support

- (void)recipeAddViewController:(RecipeAddViewController *)recipeAddViewController didAddRecipe:(Recipe *)recipe {
    
    if (recipe) {        
        // Show the recipe in the RecipeDetailViewController.
        [self performSegueWithIdentifier:kShowRecipeSegueID sender:recipe];
    }
    
    // Dismiss the RecipeAddViewController.
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    NSInteger count = self.fetchedResultsController.sections.count;
    
	if (count == 0) {
		count = 1;
	}
	
    return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSInteger numberOfRows = 0;
	
    if (self.fetchedResultsController.sections.count > 0) {
        id <NSFetchedResultsSectionInfo> sectionInfo = self.fetchedResultsController.sections[section];
        numberOfRows = sectionInfo.numberOfObjects;
    }
    
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Dequeue a RecipeTableViewCell, then set its recipe to the recipe for the current row.
    RecipeTableViewCell *recipeCell =
        (RecipeTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"MyIdentifier" forIndexPath:indexPath];
    [self configureCell:recipeCell atIndexPath:indexPath];
    
    return recipeCell;
}

- (void)configureCell:(RecipeTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
	Recipe *recipe = (Recipe *)[self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.recipe = recipe;
}


#pragma mark - UITableViewDelegate

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:kShowRecipeSegueID]) {
        // Show a recipe.
        //
        RecipeDetailViewController *detailViewController = (RecipeDetailViewController *)segue.destinationViewController;

        Recipe *recipe = nil;
        if ([sender isKindOfClass:[Recipe class]]) {
            // The sender is the actual recipe send from "didAddRecipe" delegate (user created a new recipe).
            recipe = (Recipe *)sender;
        }
        else {
            // The sender is ourselves (user tapped an existing recipe).
            NSIndexPath *indexPath = self.tableView.indexPathForSelectedRow;
            recipe = (Recipe *)[self.fetchedResultsController objectAtIndexPath:indexPath];
        }
        detailViewController.recipe = recipe;
    }
    else if ([segue.identifier isEqualToString:kAddRecipeSegueID]) {
        // Add a recipe.
        //
        Recipe *newRecipe = [NSEntityDescription insertNewObjectForEntityForName:@"Recipe"
                                                          inManagedObjectContext:self.managedObjectContext];
                
        UINavigationController *navController = segue.destinationViewController;
        RecipeAddViewController *addController = (RecipeAddViewController *)navController.topViewController;
        addController.delegate = self;  // Do didAddRecipe delegate method is called when cancel or save are tapped.
        addController.recipe = newRecipe;
    }
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the managed object for the given index path.
		NSManagedObjectContext *context = self.fetchedResultsController.managedObjectContext;
		[context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
		
		// Save the context.
		NSError *error;
		if (![context save:&error]) {
			/*
			 Replace this implementation with code to handle the error appropriately.
			 
			 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
			 */
			NSLog(@"Unresolved error %@, %@", error, error.userInfo);
			abort();
		}
	}   
}


#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController {
    
    // Set up the fetched results controller if needed.
    if (_fetchedResultsController == nil) {
        // Create the fetch request for the entity.
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        // Edit the entity name as appropriate.
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Recipe" inManagedObjectContext:self.managedObjectContext];
        fetchRequest.entity = entity;
        
        // Edit the sort key as appropriate.
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
        NSArray *sortDescriptors = @[sortDescriptor];
        
        fetchRequest.sortDescriptors = sortDescriptors;
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
        aFetchedResultsController.delegate = self;
        self.fetchedResultsController = aFetchedResultsController;
    }
	
	return _fetchedResultsController;
}

/**
 Delegate methods of NSFetchedResultsController to respond to additions, removals and so on.
 */
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    
	// The fetch controller is about to start sending change notifications, so prepare the table view for updates.
	[self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
	UITableView *tableView = self.tableView;
	
	switch(type) {
		case NSFetchedResultsChangeInsert:
			[tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeDelete:
			[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeUpdate:
			[self configureCell:(RecipeTableViewCell *)[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
			break;
			
		case NSFetchedResultsChangeMove:
			[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
	}
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
	switch(type) {
		case NSFetchedResultsChangeInsert:
			[self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeDelete:
			[self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
			break;
            
        case NSFetchedResultsChangeMove:
        case NSFetchedResultsChangeUpdate:
            break;
	}
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    
	// The fetch controller has sent all current change notifications,
    // so tell the table view to process all updates.
	[self.tableView endUpdates];
}

@end
