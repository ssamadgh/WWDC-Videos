ABUIGroups demonstrates how to retrieve, add, and remove group records
from the address book database using AddressBook APIs. It displays groups organized by their source in the address book.This sample also shows how to retrieve the name of a group and of a source.


Build Requirements:
iOS SDK 4.3 or later



Runtime Requirements:
iOS 4.0 or later



Using the Sample
Build and run the sample using Xcode 3.2.6 or later. 
The application displays a list of groups organized by sources in the 
address book. Tap on the "+" button to add a group to the default source in the address book. Tap on the Edit button to delete a group from a source. 



Packaging List

ABUIGroupsAppDelegate
The application's delegate to setup its window and content.


GroupViewController
A view controller for displaying, adding, and removing groups in the address book.


AddGroupViewController
A view controller that lets the user enter a name for a new group.


MySource
A simple class to represent a source.


Copyright (c) 2011 Apple Inc. All rights reserved.