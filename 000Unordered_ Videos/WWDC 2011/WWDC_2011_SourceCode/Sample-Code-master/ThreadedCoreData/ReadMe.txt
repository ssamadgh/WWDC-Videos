ThreadedCoreData

===========================================================================
DESCRIPTION:

This sample shows how to use Core Data in a multi-threaded environment.
Based on the SeismicXML sample, it downloads and parses an RSS feed from the United States Geological Survey (USGS) that provides data on recent earthquakes around the world.
What makes this sample different is that it persistently stores earthquakes using Core Data.
Each time you launch the app, it downloads new earthquake data, parses it in an NSOperation which checks for duplicates and stores newly founded earthquakes as managed objects.

This sample follows the first recommended pattern mentioned in the Core Data Programming Guide: Multi-Threading with Core Data; General Guidelines section - "Create a separate managed object context for each thread and share a single persistent store coordinator."

For those new to Core Data, it can be helpful to compare SeismicXML sample with this sample and notice the necessary ingredients to introduce Core Data in your application.

===========================================================================
BUILD REQUIREMENTS

iOS SDK 4.2 or later

===========================================================================
RUNTIME REQUIREMENTS

iOS OS 3.2 or later

===========================================================================
PACKAGING LIST

SeismicXMLAppDelegate
Delegate for the application, initiates the download of the XML data and parses the Earthquake objects at launch time.

Earthquake
The model class (NSManagedObject) that stores the information about an earthquake.

RootViewController
A UITableViewController subclass that manages the table view.

ParseOperation
The NSOperation class used to perform the XML parsing of earthquake data, creating managed objects based on each earthquake and stores them on the main thread.

===========================================================================
CHANGES FROM PREVIOUS VERSIONS

Version 1.0
- New Release

===========================================================================
Copyright (C) 2011 Apple Inc. All rights reserved.