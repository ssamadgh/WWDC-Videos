# Photo Memories

1. OVERVIEW
This project contains a simple cross-platform photo capture application that displays a preview of your front-facing video camera and a shutter button. Pressing the shutter button extracts a single frame from the video feed and saves it as an image on the device.

In the case of the Mac, the image is saved to ~/Pictures, and on iOS, the picture is saved to the Camera Roll.

2. ORGANIZATION
This sample code has two projects: PhotoMemories and PhotoMemoriesCore. PhotoMemories is the top-level project, and it contains all of the logic specific to each platform's app, as well as the targets to build the apps for that platform. Both targets link against code in PhotoMemoriesCore, which provides the shared logic for the app.

3. DESIGN
At a high level, there are the following groups of classes, which build upon each other:

	- Platform-specific View Controllers
	- Renderer Controllers (Platform-agnostic)
	- Model (Cross-platform)

We make the differentiation on how we handle platforms for the following reasons:

	- Platform-specific classes are ones that exist solely on iOS or OS X and have logic specific to that platform.
	- Platform-agnostic classes deal purely with cross-platform code and don't rely on any on any logic tied to a platform.
	- Cross-platform classes are cognizant of different platforms and try to present a unified interface to callers despite differences in platforms.

It is important to note that the step of breaking this logic into a library is not inherently necessary - for two key reasons:

	1) This is not referenced by more than one Xcode project.
	2) The logic is very simple.

That said, it exists as an example of how you could set up your Xcode project to use libraries in the course of sharing code between platforms.

For more detailed information about the responsibilities, patterns and rationale for each class, please consult the description in the header files.

## Requirements

### Build

iOS 7 SDK, OS X 10.9 SDK

### Runtime

iOS 7 or later, OS X 10.9 or later

Copyright (C) 2014 Apple Inc. All rights reserved.
