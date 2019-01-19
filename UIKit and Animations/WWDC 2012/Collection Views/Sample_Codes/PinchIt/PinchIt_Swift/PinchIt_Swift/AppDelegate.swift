//
//  AppDelegate.swift
//  PinchIt_Swift
//
//  Created by Seyed Samad Gholamzadeh on 5/19/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?


	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		// Override point for customization after application launch.
		self.window = UIWindow(frame: UIScreen.main.bounds)
		
		let pinchLayout = PinchLayout()
		let width: CGFloat = 120
		pinchLayout.itemSize = CGSize(width: width, height: width)
		let viewController = ViewController(collectionViewLayout: pinchLayout)
		self.window?.rootViewController = viewController
		self.window?.makeKeyAndVisible()
		
		return true
	}


}

