/*
 Copyright (C) 2017 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 Table view controller to manage an editable table view that displays information about a recipe.
  The table view uses different cell types for different row types.
 */

@class Recipe;

@interface RecipeDetailViewController : UITableViewController
            
@property (nonatomic, strong) Recipe *recipe;

@end
