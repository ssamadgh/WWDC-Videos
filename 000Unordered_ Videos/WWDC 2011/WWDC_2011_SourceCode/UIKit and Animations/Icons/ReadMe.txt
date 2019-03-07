Icons

================================================================================
ABSTRACT:

This sample demonstrates the proper use of application icons on iOS.
This is a universal binary that supports iPhone/iPod touch/iPad and includes 
support for high resolution displays.

Each icon has one dimension of the pixel dimensions on it to display which icon is being used by various areas of iOS.
The various icons display when using the Homescreen, Spotlight, the Settings app, different devices, and when creating an Ad Hoc build and adding it to iTunes.


================================================================================
BUILD REQUIREMENTS:

iOS 4.1 or later

================================================================================
RUNTIME REQUIREMENTS:

iOS 3.2 or later

================================================================================
PACKAGING LIST:

AppDelegate
The application delegate sets up the initial iPhone/iPod touch/iPad view and makes the window visible.

RootViewController
The view controller displays what each icon does on iOS.
The proper orientations supported by each device type are configured in the -shouldAutorotateToInterfaceOrientation: method.

================================================================================
CHANGES FROM PREVIOUS VERSIONS:

Version 1.0
- First version.

================================================================================
Copyright (C) 2010 Apple Inc. All rights reserved.