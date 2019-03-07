### Touches_GestureRecognizers ###

================================================================================
DESCRIPTION:

The Touches_GestureRecognizers sample application demonstrates how to handle touch events using UIGestureRecognizer introduced in iPhone OS 4.0. It shows how to handle touches, including multiple touches that move multiple objects.  After the application launches, three colored pieces appear onscreen that the user can move independently. Touches cause up to three lines of text to be displayed at the top of the screen.
 
================================================================================
BUILD REQUIREMENTS:

iOS SDK 5.0

================================================================================
RUNTIME REQUIREMENTS:

iOS 5.0 or later.

================================================================================
PACKAGING LIST:

main.m
The main entry point for the Touches application.

TouchesAppDelegate.h
TouchesAppDelegate.m
The UIApplication delegate

MyViewController.h
MyViewController.h
This view controller implements custom methods that respond to user gestures using UIGestureRecognizer.
It animates and moves pieces onscreen in response to touch events. 

================================================================================
Copyright (C) 2008-2012 Apple Inc. All rights reserved.
