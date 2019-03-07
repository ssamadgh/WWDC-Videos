QuickContacts demonstrates how to use the Address Book UI controllers and various properties such as displayedProperties, allowsAddingToAddressBook, and displayPerson.
It requires both the AddressBook and AddressBookUI frameworks.

This sample also shows how to: 
-Browse a list of Address Book contacts and allow users to choose a contact from that list.
-Display and edit information associated with a selected contact. 
-Prevent users from performing default actions such as dialing a phone number associated with a selected information.
-Create a new contact record.
-Update a partial contact record.
-Present and dismiss the people picker, person view controller, new-person view controller, and unknown-person view controller.


Build Requirements:
iOS SDK 4.0


Runtime Requirements:
iPhone OS 3.2 or later


Using the Sample
Build and run the sample using Xcode 3.2.3 or later. 
The application displays four cells labeled "Display Picker," "Create New Contact," "Display and Edit Contact," and "Edit Unknown Contact." Tap "Display Picker" to browse a list of contacts and choose a person from that list. Tap "Create New Contact" to create a new person. Tap "Display and Edit Contact" to display and edit a person. Tap "Edit Unknown Contact" to add data to an existing person or use them to create a new person.


Packaging List
main.m - Main source file for this sample.

QuickContactsAppDelegate.h
QuickContactsAppDelegate.m
The application's delegate to setup its window and content.

QuickContactsViewController.h
QuickContactsViewController.m
A view controller for managing the table.

MainWindow.xib
The nib file containing the main window.


Changes from Previous Versions
Upgraded project to build with the iOS 4.0 SDK.


Copyright (c) 2010 Apple Inc. All rights reserved.