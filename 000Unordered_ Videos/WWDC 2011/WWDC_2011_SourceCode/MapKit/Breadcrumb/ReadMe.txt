### Breadcrumb ###

===========================================================================
DESCRIPTION:

Demonstrates how to draw a path using the Map Kit overlay, MKOverlayView, that follows and tracks the user's current location.  The included CrumbPath and CrumbPathView overlay and overlay view classes can be used for any path of points that are expected to change over time.

It also demonstrates how to properly operate while running as a background process.
This application receives location events while in the background by including the "UIBackgroundModes" key (with the "location" value) in its Info.plist file.

It also uses a Core Location accuracy "kCLLocationAccuracyBestForNavigation".  This level of accuracy is intended for use in navigation applications that require precise position information.  It is strongly recommended that the device is plugged into a power source while using this level of accuracy.

Battery Power Consumption and Core Location:
How you configure Core Location services directly affects your device's battery life.  If you configure it in such a way that GPS is being used and make use of it continually (desiredAccuracy is kCLLocationAccuracyBest, or kCLLocationAccuracyNavigation), then your battery will be drained quicker.  On the other end of the spectrum, if you're only using cell positioning "kCLLocationAccuracyThreeKilometers", then the battery will last a fair bit longer.  Any use Core Location in the background will prevent the device from sleeping, which will have a noticeable effect on standby time on its own, regardless of how much power is taken up by the positioning technologies.  One idea for limiting battery consumption considering would be to use region monitoring to create a "hedge" around the device so apps can detect when the device has left a particular location.  If the device has left a certain region, then you can change the accuracy level from kCLLocationAccuracyThreeKilometers to kCLLocationAccuracyBest, or kCLLocationAccuracyNavigation.  Use of region monitoring can very battery efficient.


===========================================================================
BUILD REQUIREMENTS:

iOS 5.0 SDK or later

===========================================================================
RUNTIME REQUIREMENTS:

iOS 4.0 or later

===========================================================================
PACKAGING LIST:

CrumbPath
- Implements a mutable path of locations.

CrumbPathView
- MKOverlayView subclass that renders a CrumbPath.  Demonstrates the best way to create and render a list of points as a path in an MKOverlayView.
    
BreadcrumbViewController
- Uses MKMapView delegate messages to track the user location and update the displayed path of the user on an MKMapView.

===========================================================================
CHANGES FROM PREVIOUS VERSIONS:

Version 1.5
- Added support for MKUserTrackingMode.

Version 1.4
- Upgraded to use iOS 4.3 SDK, fixed UI issues with its settings screen.

Version 1.3
- Upgraded to iOS 4.2 SDK, fixed a bug in CrumbPath when allocating points, now checking for more GCC warnings.

Version 1.2
- Option kCLLocationAccuracyBestForNavigation turned off by default, sound feedback on location updates added as an option.

Version 1.1
- Updated to support background processing in tracking the user's location, now uses kCLLocationAccuracyBestForNavigation.

Version 1.0
- First version.

===========================================================================
Copyright (C) 2010-2011 Apple Inc. All rights reserved.
