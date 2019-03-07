
PrintWebView

=========================================================================
DESCRIPTION:

PrintWebView demonstrates how to print a UIWebView using a UIViewPrintFormatter. This application is a very primitive Web browser that has printing capability.

The sample is internationalized. See the Localized.strings file in the project's Resources/en.lproj folder.

PrintWebView shows how to:

	* Obtain and use the shared UIPrintInteraction controller.
	* Use a UIViewPrintFormatter to handle formatting and rendering of content in a webview.
	* Use a custom UIPrintPageRenderer to add a header and footer to each page.
	* Simply place a header and footer at the top and bottom of the page, positioned relative to the imageable area of the paper. To achieve this set the define SIMPLE_LAYOUT to 1 in MyPrintPageRenderer.h.
	* The code (optionally) demonstrates how to carefully place the content of the view so that it is located consistently, independent of the imageable area of the paper, e.g. inset by 1/2 inch from each edge. To achieve this, set the #define SIMPLE_LAYOUT  to 0 in MyPrintPageRenderer.h.

=========================================================================
BUILD REQUIREMENTS:

Xcode 4.2 or later.


=========================================================================
RUNTIME REQUIREMENTS:

iOS 4.2 or later.


=========================================================================
MAIN CLASSES:

MyWebViewController

The MyWebViewController class defines the controller object for the application. This object loads the nib file associated with the user interface.  The MyWebViewController class uses the UIPrintInteractionController to print, using MyPrintPageRenderer, a subclass of the UIPrintPageRenderer class.

MyPrintPageRenderer

A subclass of the UIPrintPageRenderer used to draw a header and footer on the webpage content being printed. The content of the webpage is being drawn by a UIViewPrintFormatter. MyPrintPageRenderer performs calculations to set the properties of the MyPrintPageRenderer and UIViewPrintFormatter objects so that the header and footer drawn by MyPrintPageRenderer and the content drawn by the UIViewPrintFormatter are located properly.

=========================================================================
Copyright (C) 2010, 2012 Apple Inc.  All rights reserved.
