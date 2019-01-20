/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 
  AAPLRootViewController header.
  
 */

@import UIKit;

@interface AAPLRootViewController : UICollectionViewController
{
    UISwitch *coolSwitch;
    
    id<UIViewControllerTransitioningDelegate> transitioningDelegate;
}

- (BOOL)presentationShouldBeAwesome;

@end
