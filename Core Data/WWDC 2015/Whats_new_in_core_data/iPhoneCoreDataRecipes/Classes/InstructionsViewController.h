/*
 Copyright (C) 2017 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 View controller to manage a text view to allow the user to edit instructions for a recipe.
 */

@class Recipe;

@interface InstructionsViewController : UIViewController

@property (nonatomic, strong) Recipe *recipe;

@end
