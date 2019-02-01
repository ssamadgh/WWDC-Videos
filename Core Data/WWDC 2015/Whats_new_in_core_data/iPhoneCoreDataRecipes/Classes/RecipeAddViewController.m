/*
 Copyright (C) 2017 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 View controller to allow the user to add a new recipe and choose its picture using the image picker.
  If the user taps Save, the recipe detail view controller is pushed so that the user can edit the new item.
 */

#import "RecipeAddViewController.h"
#import "Recipe.h"

@interface RecipeAddViewController () <UITextFieldDelegate>

@property (nonatomic, strong) IBOutlet UITextField *nameTextField;

@end


#pragma mark -

@implementation RecipeAddViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
        
    // Configure the navigation bar.
    self.navigationItem.title = NSLocalizedString(@"Add Recipe", "");
    
	[self.nameTextField becomeFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
	if (textField == self.nameTextField) {
		[self.nameTextField resignFirstResponder];
		[self save:self];
	}
	return YES;
}

- (IBAction)save:(id)sender {
    
    self.recipe.name = self.nameTextField.text;

	NSError *error = nil;
	if (![self.recipe.managedObjectContext save:&error]) {
		/*
		 Replace this implementation with code to handle the error appropriately.
		 
		 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
		 */
		NSLog(@"Unresolved error %@, %@", error, error.userInfo);
		abort();
	}		
    
	[self.delegate recipeAddViewController:self didAddRecipe:self.recipe];
}

- (IBAction)cancel:(id)sender {
	
	[self.recipe.managedObjectContext deleteObject:self.recipe];

	NSError *error = nil;
	if (![self.recipe.managedObjectContext save:&error]) {
		/*
		 Replace this implementation with code to handle the error appropriately.
		 
		 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
		 */
		NSLog(@"Unresolved error %@, %@", error, error.userInfo);
		abort();
	}		

    [self.delegate recipeAddViewController:self didAddRecipe:nil];
}

@end
