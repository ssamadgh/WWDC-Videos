### CoreTelephonyDemo ###

================================================================================
DESCRIPTION:

This sample shows how to use Core Telephony framework to access the user's current call, call center and carrier information.

The application uses a grouped table view with 3 sections, each section displaying one Core Telephony object.

The techniques shown in this sample are:
* correct way of instantiating Core Telephony framework objects
* using block-based event handlers to receive call events and carrier changes.
* access Core Telephony object properties

================================================================================
BUILD REQUIREMENTS:

iOS SDK 4.2.

================================================================================
RUNTIME REQUIREMENTS:

iOS 4.0.

================================================================================
PACKAGING LIST:

Application Configuration
-------------------------

CoreTelephonyDemoAppDelegate.{h,m}
MainWindow.xib
Application delegate that sets up a table view controller.


View Controllers
------------------------

RootViewController.{h,m}
RootViewController.xib
Table view controller that manages a grouped table view displaying Core Telephony objects.

================================================================================
CHANGES FROM PREVIOUS VERSIONS:

Version 1.0
- First version.

================================================================================
Copyright (C) 2011 Apple Inc. All rights reserved.