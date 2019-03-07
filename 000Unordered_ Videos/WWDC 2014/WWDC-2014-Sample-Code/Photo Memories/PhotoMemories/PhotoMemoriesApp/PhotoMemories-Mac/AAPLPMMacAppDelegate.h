//
//  AAPLPMMacAppDelegate.h
//  PhotoMemories
//
//  Copyright (c) 2014 Apple. All rights reserved.
//

/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 
  PMMacAppDelegate is responsible for handling user interactions (typing in the caption box, pressing the shutter button) and setting up
  both the text and video feed renders.
  
 */
@interface AAPLPMMacAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;

@property (weak) IBOutlet NSView *cameraFeedView;
@property (weak) IBOutlet NSTextField *captionText;

@property (nonatomic, copy) NSString *text;

@end
