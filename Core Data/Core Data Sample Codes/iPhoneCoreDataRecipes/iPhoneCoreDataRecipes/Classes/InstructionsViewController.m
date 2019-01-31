/*
 Copyright (C) 2017 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 View controller to manage a text view to allow the user to edit instructions for a recipe.
 */

#import "InstructionsViewController.h"
#import "Recipe.h"

@interface InstructionsViewController ()

@property (nonatomic, strong) IBOutlet UITextView *instructionsText;
@property (nonatomic, strong) IBOutlet UILabel *nameLabel;

@end


#pragma mark -

@implementation InstructionsViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"Instructions", "");
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    // Update the views appropriately.
    self.nameLabel.text = self.recipe.name;
    self.instructionsText.text = self.recipe.instructions;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {

    [super setEditing:editing animated:animated];

    self.instructionsText.editable = editing;
	[self.navigationItem setHidesBackButton:editing animated:YES];

	/*
	 If editing is finished, update the recipe's instructions and save the managed object context.
	 */
	if (!editing) {
		self.recipe.instructions = self.instructionsText.text;
		
		NSManagedObjectContext *context = self.recipe.managedObjectContext;
		NSError *error = nil;
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

@end
