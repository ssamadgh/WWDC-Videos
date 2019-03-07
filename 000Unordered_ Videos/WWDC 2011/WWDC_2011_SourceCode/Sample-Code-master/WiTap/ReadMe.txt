WiTap

================================================================================
DESCRIPTION:

The WiTap sample application demonstrates how to achieve network communication between applications. Using Bonjour, the application both advertises itself on the local network and displays a list of other instances of this application on the network.

Simply build the sample using Xcode and run it in the simulator or on the device. Wait for another player to connect or select a game to connect to. Once connected, tap one or more colored pads on a device to see them highlighted simultaneously on the remote device.

This sample also demonstrates peer to peer connectivity over Bluetooth, available in iOS 3.0 and later on supported hardware: Bonjour will automatically advertise and discover instances of this application over Bluetooth, and when an instance is resolved, Bonjour will automatically use Bluetooth to connect the two applications.

Checking for the presence of networking is beyond the scope of this sample.

===========================================================================
BUILD REQUIREMENTS:

Mac OS X 10.6.4, iOS 4.1 SDK

===========================================================================
RUNTIME REQUIREMENTS:

iOS 3.1.3 or later

===========================================================================
PACKAGING LIST:

AppController.h
AppController.m
UIApplication's delegate class, the central controller of the application.

TapView.h
TapView.m
UIView subclass that can highlight itself when locally or remotely tapped.

Picker.h
Picker.m
A view that displays both the currently advertised game name and a list of other games
available on the local network (discovered & displayed by BrowserViewController).

Networking/TCPServer.h
Networking/TCPServer.m
A TCP server that listens on an arbitrary port.

Networking/BrowserViewController.h
Networking/BrowserViewController.m
View controller for the service instance list.
This object manages a NSNetServiceBrowser configured to look for Bonjour services.
It has an array of NSNetService objects that are displayed in a table view.
When the service browser reports that it has discovered a service, the corresponding NSNetService is added to the array.
When a service goes away, the corresponding NSNetService is removed from the array.
Selecting an item in the table view asynchronously resolves the corresponding net service.
When that resolution completes, the delegate is called with the corresponding net service.

main.m
The main file for the WiTap application.

===========================================================================
CHANGES FROM PREVIOUS VERSIONS:

Version 1.8
- Upgraded project to build with the iOS 4.1 SDK
- Implemented an autorelease to the NSNetServiceBrowser object to release the browser once the connection is established. An active browser can cause a delay in sending packets - <rdar://problem/7000938>
- Upgraded for IPv6 as default, creates IPv4 socket is unable to create IPv6 socket.
- fixed logic bug in handleEvent to check for read method failure.

Version 1.7
- Fixed table selection and cell update bugs, and added support for handling stream errors.

Version 1.6
- Upgraded for 3.0 SDK due to deprecated APIs; in "cellForRowAtIndexPath" it now uses UITableViewCell's initWithStyle.

Version 1.5
- Updated for and tested with iPhone OS 2.0. First public release.

Version 1.4
- Updated for Beta 7.
- Code clean up.
- Improved Bonjour support.

Version 1.3
- Updated for Beta 4. 
- Added code signing.

Version 1.2
- Added icon.

Copyright (C) 2008-2010 Apple Inc. All rights reserved.