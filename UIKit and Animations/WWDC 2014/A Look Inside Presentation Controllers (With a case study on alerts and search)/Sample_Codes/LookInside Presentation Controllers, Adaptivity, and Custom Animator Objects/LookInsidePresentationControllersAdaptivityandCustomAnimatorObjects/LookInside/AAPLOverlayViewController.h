/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 
  AAPLOverlayViewController header.
  
 */

@import UIKit;
#import "AAPLPhotoCollectionViewCell.h"

@interface AAPLOverlayVibrantLabel : UILabel
@end

@interface AAPLOverlayViewController : UIViewController
{
    UIVisualEffectView *backgroundView;
    UIVisualEffectView *foregroundContentView;
    
    UIBlurEffect *blurEffect;
    UIImageView *imageView;
    
    AAPLOverlayVibrantLabel *hueLabel;
    UISlider *hueSlider;
    
    AAPLOverlayVibrantLabel *saturationLabel;
    UISlider *saturationSlider;
    
    AAPLOverlayVibrantLabel *brightnessLabel;
    UISlider *brightnessSlider;
    
    UIButton *saveButton;
    AAPLPhotoCollectionViewCell *currentPhotoView;
}

@property (nonatomic) AAPLPhotoCollectionViewCell *photoView;

@end
