AdvancedTableViewCells
======================

Demonstrates several different ways to handle complex UITableViewCells.

IndividualSubviewsBasedApplicationCell is a cell designed in Interface Builder to display the contents of a cell using individual subviews (image views, labels, etc.)

CompositeSubviewBasedApplicationCell is a cell that uses a custom view to draw all of the components of the cell.

HybridSubviewBasedApplicationCell is a cell that uses a custom view to draw most of the components of the cell while using separate views to handle components that need to animate separately from the rest of the content.


Build Requirements
------------------
iOS 4.2 SDK


Runtime Requirements
--------------------
iOS 3.2 SDK or later


Using the Sample
----------------
Open the RootViewController.m and configure which of the above three cells you wish to use using the macros at the top of the file.


Packaging List
--------------
AdvancedTableViewCellsAppDelegate.{h,m}
 - The application's delegate to setup its window and content.

RootViewController.{h,m}
- The main UITableViewController.

ApplicationCell.{h,m}
- The abstract superclass of the three cell classes described above.

IndividualSubviewBasedApplicationCell.{h,m}
- The subclass of ApplicationCell that uses individual subviews to display the content.

CompositeSubviewBasedApplicationCell.{h,m}
- The subclass of ApplicationCell that uses a single view to draw the content.

HybridSubviewBasedApplicationCell.{h,m}
- The subclass of ApplicationCell that uses a single view to draw most of the content and a separate label to render the rest of the content.

RatingView.{h,m}
- The view used by the IndividualSubviewBasedApplicationCell to display the rating.


Changes from Previous Versions
1.0 - First release
1.2 - Added reuse identifier to cell loaded from nib, added localized folder for nibs.
1.3 - Upgraded project to build with the iOS 4.0 SDK.
1.4 - Added CFBundleIconFiles in Info.plist.
1.5 - Upgraded to support iOS 4.2 SDK, now using UINib class to help load and instantiate xib-based table view cells.


Feedback and Bug Reports
Please send all feedback about this sample by connecting to the Contact ADC page.
Please submit any bug reports about this sample to the Bug Reporting page.

Copyright (C) 2009-2011, Apple Inc.