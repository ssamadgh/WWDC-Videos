//
//  AppDelegate.swift
//  Running with a Snap
//
//  Created by Seyed Samad Gholamzadeh on 7/9/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

let appDelegate = UIApplication.shared.delegate

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?
	let interfaceManager = InterfaceManager()

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		// Override point for customization after application launch.
		let defaultBackground = UIImage(named: "default_button")?.resizableImage(withCapInsets: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5), resizingMode: .stretch)
		UIButton.appearance().setBackgroundImage(defaultBackground, for: .normal)
		UIButton.appearance().contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
		
		self.window = UIWindow(frame: UIScreen.main.bounds)
		self.window?.tintColor = UIColor(red: 204.0/255.0, green: 136.0/255.0, blue: 153.0/255.0, alpha: 1.0)

		let navController = UINavigationController(rootViewController: LaunchViewController(nibName: nil, bundle: nil))
		navController.setNavigationBarHidden(true, animated: false)
		self.window?.rootViewController = navController
		
		self.window?.makeKeyAndVisible()
		self.otherSetup()
		
		return true
	}

	func otherSetup() {
		UIButton.appearance().setTitleColor(self.window!.tintColor, for: .normal)
	}

}

