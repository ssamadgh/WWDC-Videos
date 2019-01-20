# AdaptivePhotos: An Adaptive Application

This sample shows how to use new APIs introduced in iOS 8 to make your application work great on all devices and orientations. It uses size classes, traits, and additions to view controllers to make an app that works great at any size and configuration.

- The AAPLAppDelegate implements new UISplitViewController delegate methods for collapsing/expanding.
- The AAPLRatingControl class uses images for different traits along with Auto Layout to automatically resize when changing to a Vertically Compact size class.
- The AAPLOverlayView class changes its intrinsic content size depending on its size class.
- The AAPLTraitOverrideViewController class is a container view controller that forces its child view controller to have certain traits.
- The AAPLListTableViewController class shows a list of contacts that will show either a single photo as a Detail view, or a conversation view on its navigation controller
- The AAPLConversationViewController class shows a list of photos that can be shown as the Detail view
- The AAPLProfileViewController class shows a profile and changes its layout based on its vertical size class.
- The UIViewController+AAPLPhotoContents category adds support for determining what photos a view controller shows.
- The UIViewController+AAPLViewControllerShowing category adds support for determining whether calling showViewController:sender: and showDetailViewController:sender: will push.

For more information, see session 216 "Building Adaptive Apps with UIKit" from WWDC 2014.

## Requirements

### Build

iOS 8 or later

### Runtime

iOS 8 or later

Copyright (C) 2014 Apple Inc. All rights reserved.
