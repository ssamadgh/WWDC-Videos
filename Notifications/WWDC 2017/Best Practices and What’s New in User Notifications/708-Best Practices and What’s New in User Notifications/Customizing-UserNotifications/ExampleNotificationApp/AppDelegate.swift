/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Application's delegate.
*/

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?

    /// - Tag: didFinishLaunchingWithOptions
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Set up notifications.
        registerForNotificationsWithApplication(application)
        return true
    }

    func registerForNotificationsWithApplication(_ application: UIApplication) {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.delegate = self

        // Request authorization.
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { _, error in
            if let error = error {
                fatalError("failed to get authorization for notifications with \(error)")
            }
        }

        // Set up actions.
        let likeAction = UNNotificationAction(identifier: "likeAction", title: "Like", options: [.authenticationRequired])
        let reactAction = UNNotificationAction(identifier: "reactAction", title: "React", options: [.authenticationRequired])

        // Set up categories.
        let imageCategory = UNNotificationCategory(identifier: "imageCategory", actions: [likeAction, reactAction], intentIdentifiers: [], hiddenPreviewsBodyPlaceholder: NSLocalizedString("IMAGE_CATEGORY_PLACEHOLDER", comment: "image category placeholder"), options: [])
        notificationCenter.setNotificationCategories([imageCategory])

        // Register for push notifications.
        application.registerForRemoteNotifications()
    }

    /// - Tag: didRegisterForRemoteNotificationsWithDeviceToken
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // This is where you would send the token to your server.

        // Uncomment the following lines to log the device token.
        // Convert token to string.
        // let deviceTokenString = deviceToken.reduce("", { $0 + String(format: "%02X", $1) })
        // Log the token string.
        // print("ExampleNotificationApp: APNs device token - \(deviceTokenString)")
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Push notifications registration failed with \(error)")
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Allowing banners to show up in the app.
        completionHandler(.alert)
    }
}
