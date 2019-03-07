//
//  AAPLViewController.h
//  PhotoMemories-iOS
//
//  Copyright (c) 2014 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 
  AAPLViewController is responsible for handling user interactions (i.e. pressing the shutter button) and
  setting up the video feed renderer.
  
 */
@interface AAPLViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *cameraView;

@end
