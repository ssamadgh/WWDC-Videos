### PhotoPicker ###

===========================================================================
DESCRIPTION:

This sample demonstrates how to choose images from the photo library, take a picture using the device's camera, and how to customize the look of the camera's user interface.  This is done by using UIImagePickerController.  The chosen image or camera photo is displayed in a UIImageView. ÊTo customize the camera's interface, this sample shows how to use an overlay view.  With this overlay view it gives you the ability to customize the UI as you take a picture.

Among the custom features of the camera is to take a single picture, timed picture, or repeated pictures like a camera with a fast shutter speed.  Timed and shutter speed camera shots are done using the NSTimer class.

===========================================================================
BUILD REQUIREMENTS:

iOS 5.0 SDK

===========================================================================
RUNTIME REQUIREMENTS:

iOS 5.0 or later

===========================================================================
PACKAGING LIST:

AppDelegate.{h/m} -
The app delegate class used for managing the application's window and navigation controller.

MyViewController.{h/m} -
Custom UIViewController used for displaying the chosen UIImage in a UIImageView.

OverlayViewController.{h/m} -
Custom UIViewController used for managing the overlay view with the camera.

===========================================================================
CHANGES FROM PREVIOUS VERSIONS:

1.2 - Upgraded to iOS 5.0 SDK, removed some compiler warnings.
1.1 - Upgraded to iOS 4.3 SDK, fixed issue with camera overlay placement.
1.0 - First version.

===========================================================================
Copyright (C) 2010-2012 Apple Inc. All rights reserved.