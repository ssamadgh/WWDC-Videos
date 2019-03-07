### Core Image and OpenCL interopability sample ###

===========================================================================
DESCRIPTION:

This sample shows how to dehaze an image by using a custom OpenCL kernel
in conjunction with an existing Core Image image processing pipeline by
using IOSurface as the intermediate for communicating data in between
the two APIs.

The application reads source file "_DSC6843.JPG", applies the dehaze algorithm and writes the resulting output file to "/tmp/output.tiff".

===========================================================================
BUILD REQUIREMENTS:

Xcode 4.6 or later, OS X 10.8 or later

===========================================================================
RUNTIME REQUIREMENTS:

OS X 10.8 or later

===========================================================================
PACKAGING LIST:

_DSC6843.JPG - source file read by the application which is the best for showing the results of running
this algorithm.

===========================================================================
CHANGES FROM PREVIOUS VERSIONS:

Version 1.0
- First version.

===========================================================================
Copyright (C) 2013 Apple Inc. All rights reserved.
