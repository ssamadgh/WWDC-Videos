SimpleStocks

===========================================================================
ABSTRACT

The SimpleStocks sample application demonstrates how to use UIKit classes and the Core Graphics framework to draw content for iOS. From this example you will learn about UIKit's UIBezierPath class. In the sample path objects are used to both draw content and clip content. In addition you will see examples of using patterns to fill paths as well as using a path to clip images.

===========================================================================
DISCUSSION

This example shows how to use various drawing API's in UIKit.

- UIBezierPath for building simple and complex paths
- UIBezierPath for clipping
- Gradients
- How the drawing system works in UIKit
- Performance Optimizations for drawing

===========================================================================
SYSTEM REQUIREMENTS

Xcode 4.0 or later, Mac OS X 10.6.7 or later, iOS 4.2

===========================================================================
PACKAGING LIST

SimpleStocksAppDelegate
This is the App Delegate that sets up the initial view controller.

SimpleStockViewController
This view controller handles orientation changes and acts as the data source for SimpleStockView.

SimpleStockView
This is the graph view where the drawing is done.

DailyTradeInfo
The daily trade model.

DailyTradeInfoSource
The daily trade model data.

===========================================================================
CHANGES FROM PREVIOUS VERSIONS

1.0 - Initial version.

===========================================================================
Copyright (C) 2011 Apple Inc. All rights reserved.
