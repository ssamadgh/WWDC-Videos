### Locations ###

===========================================================================
DESCRIPTION:

This sample represents the completed project from the Core Data Tutorial for iPhone OS.  The application displays a list of events, which encapsulate a time stamp and a geographical location expressed in latitude and longitude, and allows the user to add and remove events.


===========================================================================
BUILD REQUIREMENTS:

iOS 4.0 SDK

===========================================================================
RUNTIME REQUIREMENTS:

iPhone OS 3.2 or later

===========================================================================
PACKAGING LIST:

LocationsAppDelegate.{h,m}
Configures the Core Data stack and the first view controllers.

RootViewController.{h,m}
Manages a table view for listing all events. Provides controls for adding and removing removing events.

Event.{h,m}
A simple managed object class to represent an event.

Locations.xcdatamodel
The Core Data managed object model for the application.

===========================================================================
CHANGES FROM PREVIOUS VERSIONS:

Version 1.3
- Added CFBundleIconFiles in Info.plist.

Version 1.2
- Upgraded project to build with the iOS 4.0 SDK.

Version 1.1
- Updated the ReadMe to reflect an update to the tutorial title.
- Added 'nonatomic' to property declarations for Event.

Version 1.0
- First version.

===========================================================================
Copyright (C) 2009-2010 Apple Inc. All rights reserved.
