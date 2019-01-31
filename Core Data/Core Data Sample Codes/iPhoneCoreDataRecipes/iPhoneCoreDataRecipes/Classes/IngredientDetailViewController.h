/*
 Copyright (C) 2017 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 Table view controller to manage editing details of a recipe ingredient -- its name and amount.
 */

@class Recipe, Ingredient;

@interface IngredientDetailViewController : UITableViewController

@property (nonatomic, strong) Recipe *recipe;
@property (nonatomic, strong) Ingredient *ingredient;

@end
