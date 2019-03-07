### DocInteraction ###

================================================================================
DESCRIPTION:

This sample how to use UIDocumentInteractionController to obtain information about documents and how to preview them.  There are two ways to preview documents: one is to use UIDocumentInteractionController's preview API, the other is directly use QLPreviewController.  This sample also demonstrates the use of UIFileSharingEnabled feature so you can upload documents to the application using iTunes and then to preview them.  With the help of "kqueue" kernel event notifications, the sample monitors the contents of the Documents folder.

In addition it leverages UIDocumentInteractionController's built-in UIGestureRecognizers (i.e. single tap = preview, tap-hold = options menu) by attaching them to the display icon.

DirectoryWatcher
An object used to help monitor the contents of the "Documents" folder by using "kqueue", a kernel event notification mechanism.
Normally apps would use these UIApplication delegate calls to scan the Documents folder for content changes:
	- (void)applicationDidBecomeActive:(UIApplication *)application;
	- (void)applicationWillResignActive:(UIApplication *)application;
With the DirectoryWatcher object, rather, you can detect changes without having to unnecessarily scan the Documents folder in numerous places in your code.

================================================================================
BUILD REQUIREMENTS:

iOS SDK 4.1 or later

================================================================================
RUNTIME REQUIREMENTS:

iOS 4.0 or later

================================================================================
CHANGES FROM PREVIOUS VERSIONS:

Version 1.4
- Upgraded to support iOS 5.0 SDK, added QLPreviewControllerDelegate to DITableViewController.h.

Version 1.3
- Upgraded to support iOS 4.2 SDK, QLPreviewController now navigates to a separate screen.

Version 1.2
- Fixed Xcode project deployment target to 4.0.

Version 1.1
- Modified and improved for previewing files in the Documents folder.

Version 1.0
- First Version, released for WWDC 2010

================================================================================
Copyright (C) 2010-2012 Apple Inc. All rights reserved.
