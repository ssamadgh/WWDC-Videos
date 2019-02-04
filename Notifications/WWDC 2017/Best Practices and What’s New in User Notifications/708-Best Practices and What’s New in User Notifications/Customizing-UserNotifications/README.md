# Customizing User Notifications

This sample code will help you understand how to schedule notifications, modify push notifications through a service extension and customize rich notifications through a content extension.

## Overview

In this sample we focus on media attachments. We have a simple single view app that sends image attachments and displays them in a custom rich notification.

### The project has three parts:
* the app itself - ExampleNotificationApp
* the service extension - MediaServiceExtension
* the content extension - ImageContentExtension

## Getting Started

### For Local Notifications:
These should work out of the box if you download and run the app. Tap the button to schedule a notification and suspend your app. The notification should fire.

### For Push Notifications:
**Note:**
You need to be part of the apple developer program in order to send push notifications.
To understand how push notifications work, go [here](https://developer.apple.com/library/content/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/APNSOverview.html).
To get your project set up for push notifications, go [here](http://help.apple.com/xcode/mac/current/#/dev11b059073).

* Once you have the correct provisioning profile and signing certificate, go to the app's project file. Under capabilities, verify that push notifications are enabled.
* To retrieve the device token: Put a breakpoint in AppDelegate's [`application(_:didRegisterForRemoteNotificationsWithDeviceToken:)`](x-source-tag://didRegisterForRemoteNotificationsWithDeviceToken) implementation or uncomment the two lines that log the device token and run the app and look in your application debugging output for "APNs device token".

## Steps for Navigating the App

1) Take a look at the AppDelegate's [`application(_didFinishLaunchingWithOptions:)`](x-source-tag://didFinishLaunchingWithOptions) method to see how to register for notifications and set up notification categories.

2) Look at the app's [`ViewController`](x-source-tag://sendLocalNotificationWithAttachment) to see how to schedule a local notification with an image attachment.

3) Go to the `AppDelegate.swift` file and see how to register for push notifications through apns. (Remember to follow the steps above "For Push Notifications" first)

4) Find a url of an image you want to send, and replace the url in the payload below. Then send a push notification with the following payload:
```
{
    'aps': {
        'alert' : 'Check out this photo!',
        'mutable-content' : 1
    },
    'url' : 'https://www.example.com/media/image.jpg',
    'type' : 'image'
}
```

6) Look at the MediaServiceExtension extension to see how to use the service extension to download the image from the url that was sent through the push payload.

7) Send yourself an image notification either through the app or the server script and 3D touch to look at the rich notification. See how we to customize this look in the ImageContentExtension.

8) Try the "Like" action and look at ImageContentExtensions's [`didReceive(_:completionHandler:)`](x-source-tag://didReceive) implementation to see how to handle that kind of action.

9) Try the "React" action and look at how to use a custom input view in the ImageContentExtension's [`NotificationViewController`](x-source-tag://NotificationViewController) to present the reactions.
