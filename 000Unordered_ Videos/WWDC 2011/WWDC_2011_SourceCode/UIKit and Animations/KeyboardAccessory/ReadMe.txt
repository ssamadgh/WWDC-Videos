### KeyboardAccessory ###

===========================================================================
DESCRIPTION:

This sample shows how to use a keyboard accessory view.

The application uses a single view controller. The view controller's view is covered by a text view. When you tap the text view, the view controller loads a nib file containing an accessory view that it adds to the text view. The accessory view contains a button. When you tap the button, the text "You tapped me." is added to the text view. The sample also shows how you can use the keyboard-will-show and keyboard-will-hide notifications to animate resizing a view that is obscured by the keyboard.

===========================================================================
BUILD REQUIREMENTS:

Xcode 3.2.2 or later, Mac OS X v10.6 or later, iPhone OS 3.2 or later

===========================================================================
RUNTIME REQUIREMENTS:

Mac OS X v10.6 or later, iPhone OS 3.2 or later

===========================================================================
PACKAGING LIST:

KeyboardAccessoryAppDelegate.{h,m}
A simple application delegate that displays the application's window. 

ViewController.{h,m}
A view controller that adds a keyboard accessory to a text view.

AccessoryView.xib
A nib file containing a keyboard accessory view.

===========================================================================
CHANGES FROM PREVIOUS VERSIONS:

Version 1.3
- viewDidUnload now releases IBOutlets, added localization support.

Version 1.2
- Updated to use new keyboard notification constants.

Version 1.0
- First version.

===========================================================================
Copyright (C) 2010 Apple Inc. All rights reserved.
