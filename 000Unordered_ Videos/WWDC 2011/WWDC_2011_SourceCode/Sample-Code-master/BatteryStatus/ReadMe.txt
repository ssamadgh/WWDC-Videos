### BatteryStatus ###

================================================================================
DESCRIPTION:

Demonstrates the use of the battery status properties and notifications provided via the iPhone OS SDK.

Testing:

The sample is only useful when run on a device. The simulator always returns unknown battery status.


================================================================================
BUILD REQUIREMENTS:

iOS 4.0 SDK

================================================================================
RUNTIME REQUIREMENTS:

iOS 3.2 or later

================================================================================
PACKAGING LIST:

BatteryStatusAppDelegate
Delegate of the main application that presents the initial window.

RootViewController
Controller for initial window. Receives battery status change notifications. Queries the
battery status and presents it in a UITableView. Enables and disables battery status updates.

================================================================================
CHANGES FROM PREVIOUS VERSIONS:

Version 1.1
	Updated for iOS 4.
	
Version 1.0
	First release.


Copyright (c) 2009-2010 Apple Inc. All rights reserved.