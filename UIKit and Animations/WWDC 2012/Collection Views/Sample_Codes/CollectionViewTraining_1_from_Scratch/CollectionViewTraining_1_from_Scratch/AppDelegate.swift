//
//  AppDelegate.swift
//  CollectionViewTraining_1_from_Scratch
//
//  Created by Seyed Samad Gholamzadeh on 7/3/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?


	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		// Override point for customization after application launch.
		self.window = UIWindow(frame: UIScreen.main.bounds)
		let flowLayout = UICollectionViewFlowLayout()
//		flowLayout.minimumLineSpacing = 0
//		flowLayout.minimumInteritemSpacing = 0
		flowLayout.headerReferenceSize = CGSize(width: 100, height: 100)
		let itemCount:CGFloat = 3
		let width = (UIScreen.main.bounds.width - (itemCount-1)*flowLayout.minimumInteritemSpacing)/itemCount
		flowLayout.itemSize = CGSize(width: width, height: width)
//		flowLayout.scrollDirection = .horizontal
//		flowLayout.sectionInset = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
		let collectionVC = CollectionViewController(collectionViewLayout: flowLayout)
		let nav = UINavigationController(rootViewController: collectionVC)
		self.window?.rootViewController = nav
		self.window?.makeKeyAndVisible()
		
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
	}

	func applicationWillTerminate(_ application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	}


}

