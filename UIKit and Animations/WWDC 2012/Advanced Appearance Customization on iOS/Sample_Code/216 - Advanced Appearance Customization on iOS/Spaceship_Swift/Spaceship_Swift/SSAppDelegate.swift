//
//  AppDelegate.swift
//  Spaceship_Swift
//
//  Created by Seyed Samad Gholamzadeh on 4/27/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

@UIApplicationMain
class SSAppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?
	var spaceship: SSSpaceship!
	
	var spaceshipPath: String {
		var path = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).last
		print(path)
		path = path?.appending("Spaceship.ship")
		return path!
	}
	
//	var spaceship: SSSpaceship
	
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		// Override point for customization after application launch.
		SSThemeManager.customizeAppAppearance()
		self.loadSpaceship()
		return true
	}

	func applicationDidEnterBackground(_ application: UIApplication) {
		self.saveSpaceship()
	}


	func applicationWillTerminate(_ application: UIApplication) {
		self.saveSpaceship()
	}

	func loadSpaceship() {
		let path = self.spaceshipPath
		self.spaceship = NSKeyedUnarchiver.unarchiveObject(withFile: path) as? SSSpaceship
		if self.spaceship == nil {
			self.spaceship = SSSpaceship()
		}
		
		NotificationCenter.default.post(name: NSNotification.Name(rawValue: SSSpaceshipDidChangeNotification), object: self.spaceship)
	}
	
	func saveSpaceship() {
		let path = self.spaceshipPath
		NSKeyedArchiver.archiveRootObject(self.spaceship, toFile: path)
	}

	
}

