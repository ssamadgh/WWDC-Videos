//
//  AppDelegate.swift
//  SimpleStocks_Swift
//
//  Created by Seyed Samad Gholamzadeh on 4/17/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.

// Abstract: This is the App Delegate that sets up the initial view controller.


import UIKit

@UIApplicationMain
class SimpleStocksAppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?


	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		// Override point for customization after application launch.
		let viewController = SimpleStockViewController()
		self.window = UIWindow(frame: UIScreen.main.bounds)
		self.window?.rootViewController = viewController
		self.window?.makeKeyAndVisible()
		return true
	}

}

