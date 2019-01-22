/*
Copyright (C) 2015 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
The app delegate. This, by design, has almost no implementation.
*/

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    // MARK: Properties

    var window: UIWindow?
    
    // MARK: UIApplicationDelegate

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        RemoteNotificationCondition.didFailToRegister(error as NSError)
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        RemoteNotificationCondition.didReceiveNotificationToken(deviceToken)
    }
}
