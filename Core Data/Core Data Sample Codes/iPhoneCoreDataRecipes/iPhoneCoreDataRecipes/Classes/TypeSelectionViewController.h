/*
 Copyright (C) 2017 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 Table view controller to allow the user to select the recipe type.
  The options are presented as items in the table view; the selected item has a check mark in the accessory view. The controller caches the index path of the selected item to avoid the need to perform repeated string comparisons after an update.
 */

@class Recipe;

@interface TypeSelectionViewController : UITableViewController

@property (nonatomic, strong) Recipe *recipe;

@end
