/*
 Copyright (C) 2017 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 View controller to manage a view to display a recipe's photo.
  The image view is created programmatically.
 */

@class Recipe;

@interface RecipePhotoViewController : UIViewController

@property(nonatomic, strong) Recipe *recipe;

@end
