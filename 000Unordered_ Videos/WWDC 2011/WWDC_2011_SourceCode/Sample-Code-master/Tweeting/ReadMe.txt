Tweeting

================================================================================
SUMMARY:

By using the Twitter framework, Accounts framework, and the NSJSONSerialization class, this sample demonstrates using the built-in Twitter composition sheet, creating a custom POST request, and downloading the public timeline from Twitter.
The "Send Easy Tweet" button checks if a Twitter account is present on the device and creates a pre-populated TWTweetComposeViewController.
This also handles the "cancel" and "send" actions from the TWTweetComposeViewController.
The "Send Custom Tweet" button utilizes the Accounts framework to create an instance of the account store on the device and then find all Twitter accounts present. In this example, the first Twitter ACAccount object found is used to pre-populate a tweet and uses a TWRequest to post the tweet using the Twitter API. This example also handles the returned response data and http response.
The "Get Public Timeline" button creates a TWRequest to get the current public timeline using the Twitter API. The response data is then converted from JSON data to an NSDictionary, using the NSJSONSerialization class.

================================================================================
MEMORY MANAGEMENT STYLE:

Automatic Reference Counting (ARC)

================================================================================
BUILD REQUIREMENTS:

Xcode 4.1 or later on OS X Snow Leopard or Xcode 4.2 or later on OS X Lion
iOS SDK 5.0 or later

================================================================================
RUNTIME REQUIREMENTS:

iOS 5.0 or later

================================================================================
CLASS LIST:

TweetingAppDelegate
This is the application delegate that sets up the initial view controller.

TweetingViewController
This view controller allows the user to send a tweet by using the built-in composition sheet or by using a custom post request. The user can additionally get the current Twitter public timeline.

================================================================================
VERSIONS:

Version 1.0
- First version.

================================================================================
Copyright (C) 2011 Apple Inc. All rights reserved.