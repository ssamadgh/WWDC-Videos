//
//  AAPLPMCSVideoFeedRenderer.h
//  PhotoMemoriesCore
//
//  Copyright (c) 2014 Apple. All rights reserved.
//

#import "AAPLPMCSImage.h"

#import <AVFoundation/AVFoundation.h>

/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 
  AAPLPMCSVideoFeedRenderer is a cross-platform object responsible for rendering the contents
  of a user's front-facing video camera as a sublayer of a target CALayer. Moreover, it offers
  the functionality of taking a snapshot, and returns a cross-platform image asynchronously
  when requested.
  
 */
@interface AAPLPMCSVideoFeedRenderer : NSObject <AVCaptureVideoDataOutputSampleBufferDelegate>

/**
 * Creates the renderer object, which adds a sublayer containing a preview video feed of the
 * user's front-facing camera to the targetLayer. Assumes the entire size frame of the target
 * layer.
 */
- (instancetype) initWithTargetCALayer:(CALayer*)targetLayer;

/**
 * Initializes AVFoundation to capture a video feed from the user's camera.
 */
- (void) configure;

/**
 * Begins capturing the user's video feed and displays it in the preview sublayer.
 */
- (void) beginRenderingToLayer;

/**
 * Stops capturing the user's video feed. Future updates to the preview sublayer are halted.
 */
- (void) stopRenderingToLayer;

/**
 * Asynchronously requests to take an image from the camera and returns a cross-platform
 * image in a block. This lets the caller caption the image and save it in a manner specific
 * to each platform.
 */
- (void) asyncCaptureImageWithCompletionHandler:(void (^)(AAPLPMCSImage*))handler;

@end
