/*
 Copyright (C) 2017 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 View controller to manage a view to display a recipe's photo.
  The image view is created programmatically.
 */

#import "RecipePhotoViewController.h"
#import "Recipe.h"

@interface RecipePhotoViewController ()

@property(nonatomic, strong) UIImageView *imageView;

@end


#pragma mark -

@implementation RecipePhotoViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Photo", @"");
    
    _imageView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageView.backgroundColor = [UIColor blackColor];
    
    self.view = self.imageView;
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    self.imageView.image = [self.recipe.image valueForKey:@"image"];
}

@end
