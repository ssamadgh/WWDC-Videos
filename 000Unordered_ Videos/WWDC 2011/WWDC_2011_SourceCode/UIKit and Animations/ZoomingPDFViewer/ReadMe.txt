### ZoomingPDFViewer ###

===========================================================================
DESCRIPTION:

This sample demonstrates how to build a PDF viewer that supports zooming in or out at any level of zooming.

The PDF page is rendered into a CATiledLayer so that it uses memory efficiently. ÊWhenever the zoom level changes a new view created at the new size and is drawn on top of the old view, this allows for crisp PDF rendering at large zoom levels.


===========================================================================
PACKAGING LIST:

View Controllers
----------------
 
ZoomingPDFViewerViewController.{h,m}
A Simple view controller to manage a PDFScrollView.
 
Views
----------------
PDFSCrollView.{h,m}
UIScrollView subclass that handles the user input to zoom the PDF page.  This class handles swapping the TiledPDFViews when the zoom level changes.

TiledPDFView.{h,m}
This view is backed by a CATiledLayer which the PDF page is rendered into.
 
Application configuration
-------------------------
 
ZoomingPDFViewerAppDelegate.{h,m}
Configures the view controller.
 
MainStoryboard.storyboard
Loaded automatically by the application. Creates the ZoomingPDFViewerViewController and its associated view.
 
 
===========================================================================
CHANGES FROM PREVIOUS VERSIONS:
 
Version 2.0
- Updated to use ARC and storyboards.
- Corrected the value of the tiled layer's levelsOfDetailBias to work correctly with high resolution devices.
 
Version 1.0
- First version.
 
===========================================================================
Copyright (C) 2010-2012 Apple Inc. All rights reserved.
