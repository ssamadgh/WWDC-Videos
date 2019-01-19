//
//  AppDelegate.swift
//  PhotoScrollerSwift
//
//  Created by Seyed Samad Gholamzadeh on 10/4/1396 AP.
//  Copyright © 1396 AP Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?
	var viewController: PhotoViewController!

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		// Add the view controller's view to the window and display.
//		self.window?.addSubview(self.viewController.view)
//		self.window?.makeKeyAndVisible()
		return true
	}
	

}

