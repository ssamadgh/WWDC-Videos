/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 
  AAPLPhotoCollectionViewCell implementation.
  
 */

#import "AAPLPhotoCollectionViewCell.h"

@implementation AAPLPhotoCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frameRect
{
    self = [super initWithFrame:frameRect];
    if (self)
    {
        imageView = [[UIImageView alloc] init];
        [imageView setContentMode:UIViewContentModeScaleAspectFill];
        
        [[self contentView] addSubview:imageView];
        [[self contentView] setClipsToBounds:YES];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [imageView setFrame:[[self contentView] bounds]];
}

- (void)setImage:(UIImage *)image
{
    [imageView setImage:image];
}

- (UIImage *)image
{
    return [imageView image];
}

@end
