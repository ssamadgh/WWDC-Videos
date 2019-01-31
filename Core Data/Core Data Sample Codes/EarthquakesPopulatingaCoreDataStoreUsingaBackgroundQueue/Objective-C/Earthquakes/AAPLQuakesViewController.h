/*
 Copyright (C) 2017 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 View controller to manage a a table view that displays a collection of quakes.
 
  When requested (by clicking the Fetch Quakes button), the controller creates an asynchronous NSURLSession task to retrieve JSON data about earthquakes. Earthquake data are compared with any existing managed objects to determine whether there are new quakes. New managed objects are created to represent new data, and saved to the persistent store on a private queue.
 */

@import Cocoa;

@interface AAPLQuakesViewController : NSViewController
@end
