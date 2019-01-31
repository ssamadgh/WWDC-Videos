# Earthquakes: Using a "private" persistent store coordinator to fetch data in background

This sample demonstrates how to set up a Core Data stack with NSPersistentContainer and use a private-queue context to import a bunch of data retrieved from a remote server. NSFetchedResultsController, which is newly avaiable on macOS 10.12 but extensively adopted on iOS, is used as the data source of NSTableView. How to do batch deletes with NSBatchDeleteRequest is also covered in this sample.

## Requirements

### Build

Xcode 8 or later, macOS v10.12 SDK or later.

### Runtime

macOS v10.12 or later.

Copyright (C) 2016 Apple Inc. All rights reserved.
