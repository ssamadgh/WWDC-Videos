//
//  AAPLViewController.m
//  PhotoMemories-iOS
//
//  Copyright (c) 2014 Apple. All rights reserved.
//

#import "AAPLViewController.h"

#import <AssetsLibrary/AssetsLibrary.h>
#import <UIKit/UIKit.h>

#import <PhotoMemoriesCore/AAPLPMCSImage.h>
#import <PhotoMemoriesCore/AAPLPMCSVideoFeedRenderer.h>

/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 
  AAPLViewController is responsible for handling user interactions (i.e. tapping the shutter button),
  setting up the video feed renderer and saving the image from the video renderer in a iOS-specific way.
  
 */
@implementation AAPLViewController
{
    AAPLPMCSVideoFeedRenderer *_videoRenderer;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    // Make sure the status bar becomes white against our black background.
    [self setNeedsStatusBarAppearanceUpdate];
	
    CALayer *cameraFeedLayer = self.cameraView.layer;
    cameraFeedLayer.backgroundColor = [UIColor blackColor].CGColor;
    
    _videoRenderer = [[AAPLPMCSVideoFeedRenderer alloc] initWithTargetCALayer:cameraFeedLayer];
    [_videoRenderer beginRenderingToLayer];
}

- (UIStatusBarStyle) preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (IBAction) takePicture:(id)sender
{
    [_videoRenderer asyncCaptureImageWithCompletionHandler:^(AAPLPMCSImage *image) {
        ALAssetsLibrary* library = [[ALAssetsLibrary alloc] init];
        
        [library writeImageToSavedPhotosAlbum:[image CGImage]
                                  orientation:ALAssetOrientationRight
                              completionBlock:^(NSURL *assetURL, NSError *error) {
            
            NSString *message;
            
            if (error == nil) {
                message = @"Photo saved to camera roll.";
            }
            else {
                message = @"Photo not saved successfully. See console for details.";
                NSLog(@"Couldn't save image to camera roll due to error: %@", error);
            }
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"PhotoMemories"
                                                            message:message
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }];
    }];
}

@end
