/*
  Copyright (C) 2017 Apple Inc. All Rights Reserved.
  See LICENSE.txt for this sample’s licensing information
  
  Abstract:
  Table view controller to manage an editable table view that displays a list of recipes.
    Recipes are displayed in a custom table view cell.
*/

#import "RecipeAddViewController.h"

@interface RecipeListTableViewController : UITableViewController

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end
