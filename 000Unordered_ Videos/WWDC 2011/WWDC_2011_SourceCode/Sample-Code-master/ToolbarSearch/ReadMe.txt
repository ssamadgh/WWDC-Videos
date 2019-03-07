
### ToolbarSearch ###

===========================================================================
DESCRIPTION:

This iPad sample shows how to use a search field in a toolbar. When you start a search, a table view displaying recent searches matching the current search string is displayed in a popover. 

The main view controller adds to a toolbar a bar button item with a search field as a custom view. If you tap the search field, the view controller presents a popover containing a list of recent searches. The list is stored in user defaults so that it persists between launches of the application, and is managed by the list's table view controller. The recents list is filtered by the current search term. If you select an item from the recents list, the item is copied to the search field, the popover dismissed, and a search executed.

===========================================================================
BUILD REQUIREMENTS:

iOS 4.3 or later

===========================================================================
RUNTIME REQUIREMENTS:

iOS 3.2 or later

===========================================================================
PACKAGING LIST:

ToolbarSearchViewController.{h,m}
A view controller that manages a search bar and a recent searches controller.

RecentSearchesController.{h,m}
A table view controller to manage and display a list of recent search strings.

ToolbarSearchAppDelegate.{h,m}
A simple application delegate to display the application's window.

===========================================================================
CHANGES FROM PREVIOUS VERSIONS:

Version 1.4
- Plugged up a memory leak, fixed bug in that the UIActionSheet no longer prematurely dismisses its parent popover, fixed bug in that the popover now properly hides/shows during rotation.

Version 1.3
- viewDidUnload now releases IBOutlets, added localization support, fixed rotation layout bug.

Version 1.2
- Prevented tap in search bar from dismissing popover. Added presentation of an alert sheet when the user taps the Clear Recents button. 

Version 1.1
- Amended method signature in delegate protocol to conform to Cocoa conventions.

Version 1.0
- First version.

===========================================================================
Copyright (C) 2010-2011 Apple Inc. All rights reserved.
