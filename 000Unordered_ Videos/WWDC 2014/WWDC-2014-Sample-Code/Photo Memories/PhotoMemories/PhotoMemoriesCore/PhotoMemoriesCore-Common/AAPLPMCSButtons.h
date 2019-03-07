//
//  AAPLPMCSButtons.h
//  PhotoMemoriesCore
//
//  Copyright (c) 2014 Apple. All rights reserved.
//

/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 
  AAPLPMCSButtons contains common drawing logic for buttons shared across both platforms.
  
 */
@interface AAPLPMCSButtons : NSObject

/**
 * Draws the cross-platform shutter button.
 * Consists of a blue circle and a camera. Constructed using bezier paths.
 */
+ (void) drawCameraButton;

@end
