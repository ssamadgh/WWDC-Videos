/*
 Copyright (C) 2017 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 View controller to allow the user to add a new recipe and choose its picture using the image picker.
  If the user taps Save, the recipe detail view controller is pushed so that the user can edit the new item.
 */

@protocol RecipeAddDelegate;

@class Recipe;

@interface RecipeAddViewController : UIViewController

@property (nonatomic, strong) Recipe *recipe;
@property (nonatomic, unsafe_unretained) id <RecipeAddDelegate> delegate;

@end


#pragma mark -

@protocol RecipeAddDelegate <NSObject>

// recipe == nil on cancel
- (void)recipeAddViewController:(RecipeAddViewController *)recipeAddViewController didAddRecipe:(Recipe *)recipe;

@end
