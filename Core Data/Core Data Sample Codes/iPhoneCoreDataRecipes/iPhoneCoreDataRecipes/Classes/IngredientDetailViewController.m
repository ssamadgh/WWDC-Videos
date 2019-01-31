/*
 Copyright (C) 2017 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 Table view controller to manage editing details of a recipe ingredient -- its name and amount.
 */

#import "IngredientDetailViewController.h"
#import "Recipe.h"
#import "Ingredient.h"
#import "EditingTableViewCell.h"

@interface IngredientDetailViewController ()

// Table's data source.
@property (nonatomic, strong) NSString *ingredientStr;
@property (nonatomic, strong) NSString *amountStr;

@end

// View tags for each UITextField.
#define kIngredientFieldTag     1
#define kAmountFieldTag         2

static NSString *IngredientsCellIdentifier = @"IngredientsCell";


@implementation IngredientDetailViewController

- (void)viewDidLoad {
    
	[super viewDidLoad];
    
    self.title = NSLocalizedString(@"Ingredient", "");
    
    self.tableView.allowsSelection = NO;
	self.tableView.allowsSelectionDuringEditing = NO;
}

- (void)setIngredient:(Ingredient *)ingredient {
    
    _ingredient = ingredient;
    
    _ingredientStr = ingredient.name;
    _amountStr = ingredient.amount;
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    EditingTableViewCell *cell =
        (EditingTableViewCell *)[tableView dequeueReusableCellWithIdentifier:IngredientsCellIdentifier
                                                                forIndexPath:indexPath];
    if (indexPath.row == 0) {
        // Cell ingredient name.
        cell.label.text = NSLocalizedString(@"Ingredient", @"");
        cell.textField.text = self.ingredientStr;
        cell.textField.placeholder = NSLocalizedString(@"Name", @"");
        cell.textField.tag = kIngredientFieldTag;
    }
	else if (indexPath.row == 1) {
        // Cell ingredient amount.
        cell.label.text = NSLocalizedString(@"Amount", @"");
        cell.textField.text = self.amountStr;
        cell.textField.placeholder = NSLocalizedString(@"Amount", @"");
        cell.textField.tag = kAmountFieldTag;
    }

    return cell;
}


#pragma mark - Save and cancel

- (IBAction)save:(id)sender {
	
	NSManagedObjectContext *context = self.recipe.managedObjectContext;
	
	// If there isn't an ingredient object, create and configure one.
    if (!self.ingredient) {
        self.ingredient = [NSEntityDescription insertNewObjectForEntityForName:@"Ingredient"
                                                        inManagedObjectContext:context];
        [self.recipe addIngredientsObject:self.ingredient];
		self.ingredient.displayOrder = [NSNumber numberWithInteger:self.recipe.ingredients.count];
    }
	
	// Update the ingredient from the values in the text fields.
    EditingTableViewCell *cell;
	
    cell = (EditingTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    self.ingredient.name = cell.textField.text;
	
    cell = (EditingTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    self.ingredient.amount = cell.textField.text;
	
	// Save the managed object context.
	NSError *error = nil;
	if (![context save:&error]) {
		/*
		 Replace this implementation with code to handle the error appropriately.
		 
		 abort() causes the application to generate a crash log and terminate.
         You should not use this function in a shipping application, although it may be
         useful during development. If it is not possible to recover from the error, display
         an alert panel that instructs the user to quit the application by pressing the Home button.
		 */
		NSLog(@"Unresolved error %@, %@", error, error.userInfo);
		abort();
	}
	
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)cancel:(id)sender {
    
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    // Editing has ended in one of our text fields, assign it's text to the right
    // ivar based on the view tag.
    //
    switch (textField.tag)
    {
        case kIngredientFieldTag:
            self.ingredientStr = textField.text;
            break;
            
        case kAmountFieldTag:
            self.amountStr = textField.text;
            break;
    }
}

@end
