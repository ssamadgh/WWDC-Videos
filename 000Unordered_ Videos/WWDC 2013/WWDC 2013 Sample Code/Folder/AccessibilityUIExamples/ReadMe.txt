### AccessibilityUIExamples ###

===========================================================================
DESCRIPTION:

Sample project for Accessibility in OS X WWDC2013 talk

===========================================================================
BUILD REQUIREMENTS:

Xcode 5.0 or later, Mac OS X v10.9 or later

===========================================================================
RUNTIME REQUIREMENTS:

Mac OS X v10.9 or later

===========================================================================
PACKAGING LIST:

./AccessibilityUIExamples/CoreTextArcViewAccessibility.h/.m - Demonstrates how to make an accessible custom single-line text view  which subclasses from NSView.
./AccessibilityUIExamples/CoreTextColumnViewAccessibility.h/.m - Demonstrates how to make an accessible custom multi-line text view which subclasses from NSView.
./AccessibilityUIExamples/CustomButtonAccessibility.h/.m - Demonstrates how to make an accessible custom button which subclasses from NSView.
./AccessibilityUIExamples/CustomImageAccessibility.h/.m - Demonstrates how to make an accessible custom image which subclasses from NSView.
./AccessibilityUIExamples/CustomStepperAccessibility.h/.m - - Demonstrates how to make an accessible custom steeper which subclasses from NSView.
./AccessibilityUIExamples/FauxUIElement.h/.m - Provides an example of a Faux UI Element class which can be instantiated to provide accessibility information for objects which don't have a backing view.
./AccessibilityUIExamples/IdealCustomButtonAccessibility.h/.m - Demonstrates how to make an accessible custom button which subclasses from NSButton.
./AccessibilityUIExamples/ProtectedTextCell.h/.m - Demonstrates how to protect text from automated assistive apps while remaining accessible to VoiceOver.
./AccessibilityUIExamples/ThreePositionSwitchCellAccessibility.h/.m - Demonstrates how to make an accessible custom three-position switch which subclasses from NSControl.
./AccessibilityUIExamples/TransientUITriggerViewAccessibility.h/.m - Demonstrates how to make controls that appear by mouse movement accessible.
./AccessibilityUIExamples/TwoPositionSwitchCell.h/.m - Demonstrates how to make an accessible custom two-position switch which subclasses from NSSlider.
./AccessibilityUIExamples/ValueIndicatorUIElement.h/.m - Demonstrates a custom faux-user-interferace element used to provide accessibility information for the value of the ThreePositionSwitch

===========================================================================
CHANGES FROM PREVIOUS VERSIONS:

Version 2.0
- Added accessibility support for two-position switches, custom images, transient UI, and protected text. 

Version 1.0
- First version.

===========================================================================
Copyright (C) 2013 Apple Inc. All rights reserved.
