/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 
  A view controller that shows a photo and its metadata.
  
 */

#import "AAPLPhotoViewController.h"
#import "AAPLPhoto.h"
#import "AAPLOverlayView.h"
#import "AAPLRatingControl.h"

@interface AAPLPhotoViewController ()
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) AAPLOverlayView *overlayButton;
@property (strong, nonatomic) AAPLRatingControl *ratingControl;
@end

@implementation AAPLPhotoViewController

- (void)loadView
{
    self.view = [[UIView alloc] init];
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.imageView = imageView;
    [self.view addSubview:imageView];
    
    AAPLRatingControl *ratingControl = [[AAPLRatingControl alloc] init];
    ratingControl.translatesAutoresizingMaskIntoConstraints = NO;
    [ratingControl addTarget:self action:@selector(changeRating:) forControlEvents:UIControlEventValueChanged];
    self.ratingControl = ratingControl;
    [self.view addSubview:ratingControl];
    
    AAPLOverlayView *overlayButton = [[AAPLOverlayView alloc] init];
    overlayButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.overlayButton = overlayButton;
    [self.view addSubview:overlayButton];
    
    [self updatePhoto];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(imageView, ratingControl, overlayButton);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[imageView]|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[imageView]|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[ratingControl]-|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[overlayButton]-|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[overlayButton]-[ratingControl]-|" options:0 metrics:nil views:views]];
    
    NSMutableArray *constraints = [NSMutableArray array];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(>=20)-[ratingControl]" options:0 metrics:nil views:views]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(>=20)-[overlayButton]" options:0 metrics:nil views:views]];
    for (NSLayoutConstraint *constraint in constraints) {
        constraint.priority = UILayoutPriorityRequired - 1;
    }
    [self.view addConstraints:constraints];
}

- (void)changeRating:(AAPLRatingControl *)sender
{
    self.photo.rating = sender.rating;
}

- (void)updatePhoto
{
    self.imageView.image = self.photo.image;
    self.overlayButton.text = self.photo.comment;
    self.ratingControl.rating = self.photo.rating;
}

- (void)setPhoto:(AAPLPhoto *)photo
{
    if (_photo != photo) {
        _photo = photo;
        [self updatePhoto];
    }
}

- (AAPLPhoto *)aapl_containedPhoto
{
    return self.photo;
}

@end
