/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 
  A category that returns information about photos contained in view controllers.
  
 */

@import UIKit;

@class AAPLPhoto;

@interface UIViewController (AAPLPhotoContents)

- (AAPLPhoto *)aapl_containedPhoto;
- (BOOL)aapl_containsPhoto:(AAPLPhoto *)photo;
- (AAPLPhoto *)aapl_currentVisibleDetailPhotoWithSender:(id)sender;

@end
