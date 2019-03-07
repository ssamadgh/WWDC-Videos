//
//  AAPLPMMacPhotoButton.m
//  PhotoMemories
//
//  Copyright (c) 2014 Apple. All rights reserved.
//

#import "AAPLPMMacPhotoButton.h"

#import <PhotoMemoriesCore/AAPLPMCSButtons.h>

/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 
  AAPLPMMacPhotoButton is a NSButton subclass that renders the cross-platform shutter image inside a button.
  
 */
@implementation AAPLPMMacPhotoButton

- (void) drawRect:(NSRect)dirtyRect
{
    [AAPLPMCSButtons drawCameraButton];
}

@end
