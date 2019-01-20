/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 
  AAPLOverlayPresentationController header.
  
 */

@import UIKit;

@interface AAPLOverlayPresentationController : UIPresentationController
{
    UIView *dimmingView;
}

@property (readonly) UIView *dimmingView;

@end
