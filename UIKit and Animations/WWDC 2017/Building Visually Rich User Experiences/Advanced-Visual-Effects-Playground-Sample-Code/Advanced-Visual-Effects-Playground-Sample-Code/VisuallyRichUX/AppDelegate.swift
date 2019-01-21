/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The application delegate is responsible for managing application lifecycle events.
*/

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = UINavigationController(rootViewController: DemoListViewController(style: .plain))
        window?.makeKeyAndVisible()
        return true
    }
}

