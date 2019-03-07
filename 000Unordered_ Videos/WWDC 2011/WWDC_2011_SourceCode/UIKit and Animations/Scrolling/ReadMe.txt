Scrolling

Demonstrates how to implement two different style UIScrollViews.   The first scroller contains multiple images, showing how to layout large content with multiple chunks of data (in our case 5 separate UIImageViews).   
The second scroller simply displays one image, matching its contentSize to the image size.  The app's primary UIViewController manages both scrollers.  Refer to this sample for best practices in how to implement content with a single image or with multiple images.


Build Requirements
iOS 4.0 SDK


Runtime Requirements
iPhone OS 3.2 or later


Using the Sample
To run in the simulator, set the Active SDK to Simulator. To run on a device, set the Active SDK to the appropriate Device setting.  When launched observe both scroll views and examine the contents of each.  Scroll through the top scroller with horizontal direction only, scroll the bottom scroll in vertical and horizontal directions.


Packaging List
main.m - Main source file for this sample.
AppDelegate.h/.m - The application's delegate to setup its window and content.
MyViewController.h/.m - The main UIViewController containing both scroll views.


Changes from Previous Versions
1.0 - First release.
1.1 - Upgraded project to build with the iOS 4.0 SDK.


Copyright (C) 2008-2010 Apple Inc. All rights reserved.