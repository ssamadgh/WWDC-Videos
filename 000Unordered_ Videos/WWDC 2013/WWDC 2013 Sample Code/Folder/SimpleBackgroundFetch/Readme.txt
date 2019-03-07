
SimpleBackgroundFetch
=====================

SimpleBackgroundFetch is a simple app that illustrates how to support background fetches.

Important: You must enable 'Background fetch' in the Background Modes capability for this feature to work properly (see the included BackgroundModeCapability images).

There are two ways to test the application:

* If you're actively debugging the application in Xcode, select Debug > Simulate Background Fetch.
* Use a scheme that simulates launching due to a background event.

The project has 2 schemes, one for regular foreground debugging and another to simulate being launched by a background fetch.
The difference is in the scheme's Run options. To see the difference, from the scheme popup menu select Edit Scheme. In the scheme editor, select the Options tab in the Run settings. Notice that in the second scheme 'Launch due to background fetch event' is selected. See the included EditScheme movie for a demonstration.

==================================================
Copyright (C) 2013 Apple Inc. All rights reserved.
