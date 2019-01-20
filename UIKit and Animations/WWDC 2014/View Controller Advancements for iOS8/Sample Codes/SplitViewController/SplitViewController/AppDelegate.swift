//
//  AppDelegate.swift
//  SplitViewController
//
//  Created by Seyed Samad Gholamzadeh on 10/17/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

	var window: UIWindow?


	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		// Override point for customization after application launch.
		
		self.window = UIWindow(frame: UIScreen.main.bounds)
		
		let controller = UISplitViewController()

		let master = TableViewController()
		let masterNav = UINavigationController(rootViewController: master)
		
		let detail = ViewController()
		
		controller.viewControllers = [masterNav, detail]
		controller.preferredDisplayMode = .primaryHidden
		controller.delegate = self
		
		self.window?.rootViewController = controller
		self.window?.makeKeyAndVisible()
		
		return true
	}

	func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
		return true
	}

}

