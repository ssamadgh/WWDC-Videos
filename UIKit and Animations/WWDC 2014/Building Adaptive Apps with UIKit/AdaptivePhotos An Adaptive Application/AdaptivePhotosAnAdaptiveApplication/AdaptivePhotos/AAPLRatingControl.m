/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 
  A control that allows viewing and editing a rating.
  
 */

#import "AAPLRatingControl.h"

NSInteger const AAPLRatingControlMinimumRating = 0;
NSInteger const AAPLRatingControlMaximumRating = 4;

@implementation AAPLRatingControl {
    UIVisualEffectView *_backgroundView;
    NSArray *_imageViews;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _rating = AAPLRatingControlMinimumRating;
        
        UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        _backgroundView = [[UIVisualEffectView alloc] initWithEffect:effect];
        _backgroundView.contentView.backgroundColor = [UIColor colorWithWhite:0.7 alpha:0.3];
        [self addSubview:_backgroundView];
        
        NSMutableArray *imageViews = [NSMutableArray array];
        for (NSInteger rating = AAPLRatingControlMinimumRating; rating <= AAPLRatingControlMaximumRating; rating++) {
            UIImageView *imageView = [[UIImageView alloc] init];
            imageView.userInteractionEnabled = YES;
            
            // Set up our image view's images
            [imageView setImage:[UIImage imageNamed:@"ratingInactive"]];
            [imageView setHighlightedImage:[UIImage imageNamed:@"ratingActive"]];
            
            [imageView setAccessibilityLabel:[NSString stringWithFormat:NSLocalizedString(@"%d stars", @"%d stars"), rating + 1]];
            [self addSubview:imageView];
            [imageViews addObject:imageView];
        }
        
        _imageViews = [imageViews copy];
        [self updateImageViews];
        [self setupConstraints];
    }
    return self;
}



- (void)setupConstraints
{
    _backgroundView.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary *views = @{@"backgroundView" : _backgroundView};
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[backgroundView]|" options:0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[backgroundView]|" options:0 metrics:nil views:views]];
    
    UIImageView *lastImageView = nil;
    for (UIImageView *imageView in _imageViews) {
        imageView.translatesAutoresizingMaskIntoConstraints = NO;
        
        NSDictionary *currentImageViews = (lastImageView ? NSDictionaryOfVariableBindings(imageView, lastImageView) : NSDictionaryOfVariableBindings(imageView));
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-4-[imageView]-4-|" options:0 metrics:nil views:currentImageViews]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:imageView attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0]];
        if (lastImageView) {
            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[lastImageView][imageView(==lastImageView)]" options:0 metrics:nil views:currentImageViews]];
        } else {
            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-4-[imageView]" options:0 metrics:nil views:currentImageViews]];
        }
        
        lastImageView = imageView;
    }
	
    NSDictionary *currentImageViews = NSDictionaryOfVariableBindings(lastImageView);
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[lastImageView]-4-|" options:0 metrics:nil views:currentImageViews]];
}

- (void)updateImageViews
{
    [_imageViews enumerateObjectsUsingBlock:^(UIImageView *imageView, NSUInteger imageViewIndex, BOOL *stop) {
        imageView.highlighted = (imageViewIndex + AAPLRatingControlMinimumRating <= self.rating);
    }];
}

- (void)setRating:(NSInteger)value
{
    if (_rating != value) {
        _rating = value;
        [self updateImageViews];
    }
}

#pragma mark - Touches

- (void)updateRatingWithTouches:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint position = [touch locationInView:self];
    UIView *touchedView = [self hitTest:position withEvent:event];
    
    if ([_imageViews containsObject:touchedView]) {
        self.rating = AAPLRatingControlMinimumRating + [_imageViews indexOfObject:touchedView];
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self updateRatingWithTouches:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self updateRatingWithTouches:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{}

#pragma mark - Accessibility

- (BOOL)isAccessibilityElement
{
    return NO;
}

@end
