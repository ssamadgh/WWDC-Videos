//
//  AppDelegate.swift
//  Reminders_Swift
//
//  Created by Seyed Samad Gholamzadeh on 3/18/19.
//  Copyright © 2019 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit
import UserNotifications
import CoreLocation

@UIApplicationMain
class RemindersAppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

	@IBOutlet var window: UIWindow?
	@IBOutlet var viewController: RemindersViewController!

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		// Override point for customization after application launch.
		UNUserNotificationCenter.current().delegate  = self
		requestNotificationAuthorization()
		self.window?.rootViewController = self.viewController
		self.window?.makeKeyAndVisible()
		application.applicationIconBadgeNumber = 0
		
		return true
	}

	func applicationWillResignActive(_ application: UIApplication) {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
	}

	func applicationDidEnterBackground(_ application: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	}

	func applicationWillEnterForeground(_ application: UIApplication) {
		// Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
	}

	func applicationDidBecomeActive(_ application: UIApplication) {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
		application.applicationIconBadgeNumber = 0
	}

	func applicationWillTerminate(_ application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	}

	func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
		
		if UIApplication.shared.applicationState == .active {
			// We're active, thus no UI was previously displayed to the user, display our own
			let alertController = UIAlertController(title: "Reminder", message: response.notification.request.content.body, preferredStyle: .alert)
			alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
			self.window?.rootViewController?.present(alertController, animated: true, completion: nil)
		}
		// Developers should consider taking the user to the Reminder detail view.

	}
	
	func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
		completionHandler([.alert, .sound])
	}
	
	func didEnter(_ region: CLRegion) {
		//Create Notification
		
		// add the region to the payload so it can optionally be handled with application:didReceiveLocalNotification:
//		scheduleNotificationFor(region: region, body: "Remember to \(region.identifier)?")
	}
	
	func didExit(_ region: CLRegion) {
		//Create Notification

		// add the region to the payload so it can optionally be handled with application:didReceiveLocalNotification:
//		scheduleNotificationFor(region: region, body: "Did you remember to \(region.identifier)?")

	}
	

	
	func requestNotificationAuthorization() {
		let center = UNUserNotificationCenter.current()
		// Request permission to display alerts and play sounds.
		center.requestAuthorization(options: [.alert, .sound, .badge])
		{ (granted, error) in
			// Enable or disable features based on authorization.
		}
	}
	
}

