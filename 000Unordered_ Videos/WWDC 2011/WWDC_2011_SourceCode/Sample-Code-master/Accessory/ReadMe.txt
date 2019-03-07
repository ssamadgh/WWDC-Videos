Accessory

Demonstrates how to implement a custom accessory view for your UITableView in the form of a checkmark button. It shows you how to override the appearance or control of the accessory view, much like that of "UITableViewCellAccessoryDetailDisclosureButton". It implements the custom accessory view by setting the table's "accessoryView" property with a UIButton of type "UIButtonTypeCustom". It can be toggled by selecting the entire table row by implementing UITableView's "didSelectRowAtIndexPath". The green checkmark is trackable (checked/unchecked), and can be toggled independent of table selection.


Build Requirements
iOS 4.0 SDK


Runtime Requirements
iPhone OS 3.2 or later


Using the Sample
Launch the Accessory project using Xcode.

To run in the simulator, set the Active SDK to Simulator. To run on a device, set the Active SDK to the appropriate Device setting. When launched, touch the entire row to make the accessory view appear checked, touch again to uncheck it. Then touch the actual accessory to the right to check and uncheck it as well.


Packaging List
main.m - Main source file for this sample.
AppDelegate.h/.m - The application's delegate to setup its window and content.
MyTableViewController.h/.m - The main UITableViewController controlling the UITableView and its custom accessory view.


Changes from Previous Versions
1.0 - First release.
1.1 - Upgraded for 3.0 SDK due to deprecated APIs; in "cellForRowAtIndexPath" it now uses UITableViewCell's initWithStyle.
1.2 - Upgraded project to build with the iOS 4.0 SDK.

Copyright (C) 2008-2010 Apple Inc. All rights reserved.