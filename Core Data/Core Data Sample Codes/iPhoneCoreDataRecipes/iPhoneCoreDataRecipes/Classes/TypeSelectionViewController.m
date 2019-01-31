/*
 Copyright (C) 2017 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 Table view controller to allow the user to select the recipe type.
  The options are presented as items in the table view; the selected item has a check mark in the accessory view. The controller caches the index path of the selected item to avoid the need to perform repeated string comparisons after an update.
 */

#import "TypeSelectionViewController.h"
#import "Recipe.h"

@interface TypeSelectionViewController()

@property (nonatomic, strong) NSArray *recipeTypes;

@end


#pragma mark -

@implementation TypeSelectionViewController

static NSString *MyIdentifier = @"MyIdentifier";

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
	self.title = NSLocalizedString(@"Category", "");
    
    // Right bar button item will dismiss this view controller.
    self.navigationItem.rightBarButtonItem =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                  target:self
                                                  action:@selector(doneAction:)];
    
    // Fetch the recipe types in alphabetical order by name from the recipe's context.
	NSManagedObjectContext *context = self.recipe.managedObjectContext;
	
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	fetchRequest.entity = [NSEntityDescription entityForName:@"RecipeType" inManagedObjectContext:context];
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:&sortDescriptor count:1];
	fetchRequest.sortDescriptors = sortDescriptors;
    NSArray *types = [context executeFetchRequest:fetchRequest error:nil];
	self.recipeTypes = types;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
     
    // Register this class for our cell to this table view under the specified identifier 'MyIdentifier'.
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:MyIdentifier];
}

- (IBAction)doneAction:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    // Number of rows is the number of recipe types.
    return self.recipeTypes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier forIndexPath:indexPath];
    
    // Configure the cell.
	NSManagedObject *recipeType = (self.recipeTypes)[indexPath.row];
    cell.textLabel.text = [recipeType valueForKey:@"name"];
    
    if (recipeType == self.recipe.type) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    return cell;
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
    // If there was a previous selection, unset the accessory view for its cell.
	NSManagedObject *currentType = self.recipe.type;
	
    if (currentType != nil) {
		NSInteger index = [self.recipeTypes indexOfObject:currentType];
		NSIndexPath *selectionIndexPath = [NSIndexPath indexPathForRow:index inSection:0];
        UITableViewCell *checkedCell = [tableView cellForRowAtIndexPath:selectionIndexPath];
        checkedCell.accessoryType = UITableViewCellAccessoryNone;
    }

    // Set the checkmark accessory for the selected row.
    [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;    

     // Update the type of the recipe instance.
    self.recipe.type = (self.recipeTypes)[indexPath.row];
    
    // Deselect the row.
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
