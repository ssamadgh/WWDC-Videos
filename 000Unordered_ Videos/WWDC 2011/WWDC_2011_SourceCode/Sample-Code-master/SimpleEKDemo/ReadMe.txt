### SimpleEKDemo ###

================================================================================
DESCRIPTION:

This sample shows how to use EventKit and EventKitUI frameworks to access and edit calendar data in the Calendar database.

The application uses table views to display EKEvent objects retrieved from an EKEventStore object. It implements EKEventViewController for viewing and editing existing EKEvents, and uses EKEventEditViewController for creating new EKEvents.

Amongst the techniques shown are how to:
* Create and initialize an event store object.
* Create a predicate, or a search query for the Calendar database.
* Override EKEventEditViewDelegate method to respond to editing events.
* Access event store, calendar and event properties. 

================================================================================
BUILD REQUIREMENTS:

Mac OS X v10.6 or later; Xcode 3.1.3 or later; iPhone OS 4.0.

================================================================================
RUNTIME REQUIREMENTS:

iPhone OS 4.0.

================================================================================
PACKAGING LIST:

Application Configuration
-------------------------

SimpleEKDemoAppDelegate.{h,m}
MainWindow.xib
Application delegate that sets up a tab bar controller with a root view controller -- a navigation controller that in turn loads a table view controller to manage a list of calendars.


View Controllers
------------------------

RootViewController.{h,m}
RootViewController.xib
Table view controller that manages a table view displaying a list of events fetched from the default calendar.

===========================================================================
CHANGES FROM PREVIOUS VERSIONS:

Version 1.0
- First version.

================================================================================
Copyright (C) 2010 Apple Inc. All rights reserved.