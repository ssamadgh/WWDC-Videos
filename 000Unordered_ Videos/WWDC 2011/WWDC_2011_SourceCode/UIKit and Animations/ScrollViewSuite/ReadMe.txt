### ScrollViewSuite ###

===========================================================================
DESCRIPTION:

A series of examples that illustrate how to use UIScrollView.

1_TapToZoom demonstrates:
* Fitting the image to the screen on launch
* Detecting single, double, and two-finger taps using UIGestureRecognizer
* Zooming in response to taps

2_Autoscroll adds a thumbnail scroll view, and demonstrates:
* Use of the canCancelContentTouches property to track moving touches in a subview of a scroll view
* How to implement autoscrolling in response to a subview being dragged

3_Tiling demonstrates:
* How to subclass UIScrollView to add content tiling
* Reusing tiles to optimize performance and memory use
* Changing the resolution of the content in response to zooming

===========================================================================
BUILD REQUIREMENTS:

Xcode 3.2 or later, Mac OS X v10.6 or later, iOS v4.1.

===========================================================================
RUNTIME REQUIREMENTS:

iOS v4.0.

===========================================================================
PACKAGING LIST:


1_TapToZoom
-----------

AppDelegate.{h,m}
Application delegate to configure the application window.


RootViewController.{h,m}
View controller to manage a scrollview that displays a zoomable image.



2_Autoscroll
------------

AppDelegate.{h,m}
Application delegate to configure the application window.


RootViewController.{h,m}
View controller to manage a scrollview that displays a zoomable image and a collection of thumbnail images.


TapDetectingImageView.{h,m}
UIImageView subclass that responds to taps and notifies its delegate.


ThumbImageView.{h,m}
UIImageView subclass to display a thumbnail image; notifies a delegate of various interactions.



3_Tiling
--------

AppDelegate.{h,m}
Application delegate to configure the application window.


RootViewController.{h,m}
View controller to manage a scrollview that displays a zoomable image and a collection of thumbnail images.


TapDetectingView.{h,m}
UIView subclass that responds to taps and notifies its delegate.


ThumbImageView.{h,m}
UIImageView subclass to display a thumbnail image; notifies a delegate of various interactions.


TiledScrollView.{h,m}
UIScrollView subclass to manage tiled content.





===========================================================================
CHANGES FROM PREVIOUS VERSIONS:

Version 1.3
- Removed TapDetectingImageView since it is no longer used.

Version 1.2
- Updated 1_TapToZoom to use Interface Builder for building the UI objects.

Version 1.1
- Updated artwork.

Version 1.0
- First version.

===========================================================================
Copyright (C) 2010 Apple Inc. All rights reserved.
