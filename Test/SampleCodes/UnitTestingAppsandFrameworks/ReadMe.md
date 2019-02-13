# UnitTests
UnitTests demonstrates how to implement unit tests and UI tests. It is a workspace that contains two projects: Calc and Calc (macOS).
Calc builds an iOS app and CalculatorKit. Calc (macOS) builds an macOS app and a macOS version of CalculatorKit. Both apps use 
CalculatorKit, which is a framework, to process user input and perform related arithmetic operations.


## Build Requirements
+ Xcode 9.3 or later
+ iOS 11.3 SDK or later
+ macOS 10.13 SDK or later


## Runtime Requirements
+ iOS 9.3 or later
+ mac OS 10.11 or later


### iOS
The Calc project defines two schemes:
Calc
Builds the Calc app and performs its UI tests.


CalculatorKit
Builds the CalculatorKit framework. Performs unit tests on the Calculator class.


### macOS
Calc (macOS)
Builds the macOS Calc app and performs its UI tests.

CalculatorKit (macOS)
Builds the macOS version of CalculatorKit. Performs unit tests on the Calculator class.


### Running Unit Tests

To run unit tests,
1. From the Scheme pop-up menu in the toolbar, select CalculatorKit (iOS) > <device_simulator> or CalculatorKit (macOS) > <Mac>
2. Use either of the following approaches to proceed:
a. Choose Product > Test to run all the test cases implemented in the Calculator.m file, then navigate to View > Navigators > Show Report Navigator to view the test results.
See [Xcode Help > Run and Debug > View and filter logs and reports](http://help.apple.com/xcode/mac/current/#/dev21d56ecd4) for more information.

b. Choose View > Navigators > Show Test Navigator to navigate to the Test navigator. Hover the pointer over any test target or test class to display a run button, then click
the button to run the tests. See [Xcode Help > Run UI tests and unit tests](http://help.apple.com/xcode/mac/current/#/dev42b289fbc) for more information.


## Running UI Tests

To run UI tests,
1. From the Scheme pop-up menu in the toolbar, select Calc (iOS) > <device> or Calc (macOS) > <Mac>.
2. Use either of the following approaches to proceed:
a. Choose Product > Test to run all the test cases implemented in the Calculator.m file, then navigate to View > Navigators > Show Report Navigator to view the test results.
   See [Xcode Help > Run and Debug > View and filter logs and reports](http://help.apple.com/xcode/mac/current/#/dev21d56ecd4) for more information.

b. Choose View > Navigators > Show Test Navigator to navigate to the Test navigator. Hover the pointer over any test target or test class to display a run button, then click
   the button to run the tests. See [Xcode Help > Run UI tests and unit tests](http://help.apple.com/xcode/mac/current/#/dev42b289fbc) for more information.


Copyright (C) 2012-2018 Apple Inc. All rights reserved.
