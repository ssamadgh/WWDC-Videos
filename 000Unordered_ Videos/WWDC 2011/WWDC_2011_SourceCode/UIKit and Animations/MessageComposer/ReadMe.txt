### MessageComposer ###

================================================================================
DESCRIPTION:

MessageComposer demonstrates how to target older OS versions while building
with newly released APIs. It also illustrates how to use the MessageUI framework to compose and send email and SMS messages from within your application.
This application uses the MFMailComposeViewController and MFMessageComposeViewController classes of the MessageUI framework, which were respectively introduced in iPhone SDK 3.0 and iPhone SDK 4.0. These two classes manage user interfaces that allows users to compose and send email and SMS messages from within their applications, respectively.

MessageComposer displays two buttons labeled "Compose Mail" and "Compose SMS."
When users tap on "Compose Mail" and "Compose SMS," the application respectively shows an email composition interface and an SMS composition interface. 
The application shows either of these composition interfaces if their respective classes exist and the device is configured for sending email or SMS. It provides a feedback message, otherwise.

MessageComposer runs on earlier and later releases of the iOS and uses
new APIs introduced in iPhone SDK 4.0. See below for steps that describe how to target earlier 0S versions while building with newly released APIs.
 
 
1. Set your iOS Deployment Target setting to your application's target
iOS release
This setting indicates the earliest iOS on which your application can
run. We set it to iOS 3.0.


2. Set the Base SDK to the desired iPhone SDK 
This setting indicates what release of the iPhone SDK will be used to build
your application. We set it to iPhone SDK 3.0 in order to take advantage of  all
the features of the new MessageUI framework. 


3. Make MessageUI a weak framework (set its role to Weak)
An application will fail to launch or proceed if it attempts to load a
framework on devices where this framework is absent. 
With weak linking, an application does not fail, but proceeds when a symbol or
framework is not present at runtime. All weak-linked symbols are set to NULL on
devices without them.

To designate MessageUI as weak-linked, select the target's Link Binary With
Libraries build phase, then change MessageUI's role from Required to Weak in the
detail view.


4. Check for the existence of APIs before calling them
MessageComposer will crash if it attempts to use non-existent weak-linked symbols.
The showPicker method checks whether
MFMailComposeViewController/MFMessageComposeViewController exists (is non-NULL)
before using it.


5. Provide a workaround for non-existent APIs
If MFMailComposeViewController/MFMessageComposeViewController does not exist,
it shows a feedback message informing that the device is not configured to send
email or SMS. 


Further Reading
Running Applications section of the iPhone Development Guide
<http://developer.apple.com/iphone/library/documentation/Xcode/Conceptual/iphone_development/120-Running_Applications/running_applications.html>


Frameworks and Weak Linking
<http://developer.apple.com/DOCUMENTATION/MacOSX/Conceptual/BPFrameworks/Concepts/WeakLinking.html>

================================================================================
BUILD REQUIREMENTS:

Mac OS X 10.6 or later, Xcode 3.2 or later, iOS 4.1
 
================================================================================
RUNTIME REQUIREMENTS:

iOS 3.0 or later
  
Using the Sample
Build and run the sample using Xcode 3.2 or later. 
Tap the "Compose Mail" button to display an email composition interface if your device is running iOS 3.0; tap the "Compose SMS" button to display an SMS composition interface if your device is running iOS 4.0. Otherwise display feedback message.
 
================================================================================
PACKAGING LIST:

Application Configuration
-------------------------

MessageComposerAppDelegate.{h,m}
MainWindow.xib
Application delegate that sets up a UIViewController with two UIButton's and a
UILabel. 


View Controllers
------------------------

MessageComposerViewController.{h,m}
MessageComposerViewController.xib
UIViewController that includes two UIButton's and a UILabel.

===========================================================================
CHANGES FROM PREVIOUS VERSIONS:
Version 1.1
- Changed the rainy.png image into JPEG format, because PNG-optimization made it unreadable on some platforms when sent as an attachment.
Version 1.0
- First version (Formerly known as MailComposer).

================================================================================
Copyright (C) 2010 Apple Inc. All rights reserved.