//
//  AppDelegate.swift
//  iOS7ScrollViews_Siwft
//
//  Created by Seyed Samad Gholamzadeh on 7/7/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

@UIApplicationMain
class SVAppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?


	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		// Override point for customization after application launch.
		self.window = UIWindow(frame: UIScreen.main.bounds)
		let viewControlller = SVViewController(nibName: nil, bundle: nil)
		self.window?.rootViewController = viewControlller
		
		self.window?.backgroundColor = UIColor.white
		self.window?.makeKeyAndVisible()
		
		return true
	}

}

