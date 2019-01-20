/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 
  A view that shows a textual overlay whose margins change with its vertical size class.
  
 */

#import "AAPLOverlayView.h"

@implementation AAPLOverlayView {
    UILabel *_label;
}

- (CGSize)intrinsicContentSize
{
    CGSize size = [_label intrinsicContentSize];
    
    // Add a horizontal margin whose size depends on our horizontal size class
    if (self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassCompact) {
        size.width += 4.0;
    } else {
        size.width += 40.0;
    }
    
    // Add a vertical margin whose size depends on our vertical size class
    if (self.traitCollection.verticalSizeClass == UIUserInterfaceSizeClassCompact) {
        size.height += 4.0;
    } else {
        size.height += 40.0;
    }
    
    return size;
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection
{
    [super traitCollectionDidChange:previousTraitCollection];
    if ((self.traitCollection.verticalSizeClass != previousTraitCollection.verticalSizeClass)
        || (self.traitCollection.horizontalSizeClass != previousTraitCollection.horizontalSizeClass)) {
        // If our size class has changed, then our intrinsic content size will need to be updated
        [self invalidateIntrinsicContentSize];
    }
}



- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIVisualEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        UIVisualEffectView *backgroundView = [[UIVisualEffectView alloc] initWithEffect:effect];
        backgroundView.contentView.backgroundColor = [UIColor colorWithWhite:0.7 alpha:0.3];
        backgroundView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:backgroundView];
        NSDictionary *views = @{@"backgroundView" : backgroundView};
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[backgroundView]|" options:0 metrics:nil views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[backgroundView]|" options:0 metrics:nil views:views]];
        
        _label = [[UILabel alloc] init];
        _label.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_label];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_label attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_label attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
    }
    return self;
}

- (NSString *)text
{
    return _label.text;
}

- (void)setText:(NSString *)text
{
    _label.text = text;
    [self invalidateIntrinsicContentSize];
}

@end
