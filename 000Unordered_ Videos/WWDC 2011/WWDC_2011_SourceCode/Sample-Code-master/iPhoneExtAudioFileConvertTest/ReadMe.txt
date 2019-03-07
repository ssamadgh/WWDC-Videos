iPhoneExtAudioFileConvertTest

===========================================================================
DESCRIPTION:

iPhoneExtAudioFileConvertTest demonstrates the use of the ExtAudioFile API to convert from one audio format and file type to another.

All the relevant code is in the file ExtAudioFileConvert.cpp.

Touching the "Convert" button calls the function DoConvertFile() producing an output.caf file using the
encoding and sample rate chosen in the UI. The output.caf file is then played back after conversion using AVAudioPlayer
to confirm success.

Audio format information for the source file and output file are also displayed.

Interruption handling during audio processing (conversion) is also demonstrated.
 
===========================================================================
RELATED INFORMATION:

Core Audio Overview
Extended Audio File Services Reference

===========================================================================
SPECIAL CONSIDERATIONS:

AAC encoding requires iPhone OS 3.1 and a hardware capable device such as the iPhone 3GS. See IsAACHardwareEncoderAvailable
function in MyViewController.m

===========================================================================
BUILD REQUIREMENTS:

iOS 4.0 SDK

===========================================================================
RUNTIME REQUIREMENTS:

iOS 4.0 or later

===========================================================================
PACKAGING LIST:

iPhoneExtAudioFileConvertTest.h
iPhoneExtAudioFileConvertTest.m

The ExtAudioFileConvertAppDelegate class defines the application delegate object, responsible for adding the navigation
controllers view to the application window.

MyViewController.h
MyViewController.m

The MyViewController class defines the controller object for the application. The object helps set up the user interface,
responds to and manages user interaction, and implements sound playback.

ExtAudioFileConvert.cpp

This file implements the DoConvertFile function which is called on a background thread from the MyViewController class.

All the code demonstrating how to perform conversion is contained in this one file, the rest of the sample may be thought of
as a simple framework for the demonstration code in this file.

Audio Format and Sample Rate choices presented in the UI are simply used for testing purposes, developers are free to choose any other
supported file type or encoding format and present these choices however they wish.

===========================================================================
CHANGES FROM PREVIOUS VERSIONS:

Version 1.0, tested with iPhone OS 3.1. First public release.
Version 1.1, tested with iPhone OS 4.0. Upgraded project to build with the iOS 4.0 SDK.

================================================================================
Copyright (C) 2009-2010 Apple Inc. All rights reserved.