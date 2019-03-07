
CollectionView-Simple
---------------------

Demonstrates how to use UICollectionView, a way to present ordered data to users in a grid-like fashion.  With a collection view object, you are able to define the presentation and arrangement of embedded views.  The collection view class works closely with an accompanying layout object to define the placement of individual data items.  In this example UIKit provides a standard flow-based layout object that you can use to implement multi-column grids containing items of a standard size.

This application also demonstrates the use of Application State Restoration features introduced in iOS 7. If the application exits, it will restore the previous state the next time it starts. 

(Note that if you quit the application from the Switcher, it will not restore state on the next launch, so for testing, exit the application from Xcode.)

To manipulate images, select one from the collection view, then you can do the following:

Single tap will hide/show the Navigation/Tool/StatusBar
Pinch and zoom with two fingers resizes the image
Double tap alternates between zoom and normal size for the image
The Blur and Sepia buttons on the bottom right present a filter controller to manipulate the image.

In this example, the following state is saved and restored:

CollectionView scroll position.
Selected cell in CollectionView.
Displayed Image.
CGAffineTransform for displayed image
Visible/hidden state of Navigation/Tool/StatusBar when image is showing
Presented Filter Controller
Filter settings for image

Additionally, if the Mail Activity is selected, to compose Mail, that will be saved and restored.

==================================================
Copyright (C) 2012 Apple Inc. All rights reserved.
