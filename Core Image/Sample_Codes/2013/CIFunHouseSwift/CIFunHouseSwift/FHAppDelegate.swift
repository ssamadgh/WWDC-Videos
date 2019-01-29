//
//  AppDelegate.swift
//  CIFunHouseSwift
//
//  Created by Seyed Samad Gholamzadeh on 8/7/1396 AP.
//  Copyright © 1396 AP Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit
import CoreMotion

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?
	var motionManager: CMMotionManager?
	var realDeviceOrientation: UIDeviceOrientation {
		let deviceMotion = motionManager!.deviceMotion!
		
		let x = deviceMotion.gravity.x
		let y = deviceMotion.gravity.y
		
		if (fabs(y) >= fabs(x))
		{
			if (y >= 0) {
				return UIDeviceOrientation.portraitUpsideDown
			} else {
				return UIDeviceOrientation.portrait
			}
		}
		else
		{
			if (x >= 0) {
				return UIDeviceOrientation.landscapeRight
			} else {
				return UIDeviceOrientation.landscapeLeft
			}
		}
	}

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		// Override point for customization after application launch.
//		self.window?.makeKeyAndVisible()
//		
//		// initialize the motion manager
//		motionManager = CMMotionManager()
//		motionManager?.deviceMotionUpdateInterval = 0.1 //10 Hz
		return true
	}
	
	func applicationDidBecomeActive(_ application: UIApplication) {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
		
		motionManager?.startDeviceMotionUpdates()
	}

	func applicationWillResignActive(_ application: UIApplication) {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
		
		motionManager?.stopDeviceMotionUpdates()
	}
	

}

