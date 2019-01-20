//
//  AppDelegate.swift
//  TicTacToeApp_Swift
//
//  Created by Seyed Samad Gholamzadeh on 7/9/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?
	var profile: TTTProfile!
	
	var profileURL: URL = {
		var url = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
		url = url.appendingPathComponent("Profile.ttt")
		return url
	}()

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		// Override point for customization after application launch.
		UINavigationBar.appearance().setBackgroundImage(UIImage(named: "navigationBarBackground"), for: .default)
		UINavigationBar().titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.black]
		
		let profileURL = self.profileURL
		self.profile = self.loadProfile(with: profileURL)
		
		self.window = UIWindow(frame: UIScreen.main.bounds)
		let viewController1 = TTTPlayViewController.viewController(with: self.profile, profileURL: profileURL)
		let viewController2 = TTTMessagesViewController.viewController(with: self.profile, profileURL: profileURL)
		let viewController3 = TTTProfileViewController.viewController(with: self.profile, profileURL: profileURL)
		let tabBarController = UITabBarController()
		tabBarController.viewControllers = [viewController1, viewController2, viewController3]
		tabBarController.tabBar.backgroundImage = UIImage(named: "barBackground")
		self.window!.rootViewController = tabBarController
		self.updateTintColor()
		self.window!.makeKeyAndVisible()
		
		NotificationCenter.default.addObserver(self, selector: #selector(iconDidChange(_:)), name: NSNotification.Name(rawValue: TTTProfileIconDidChangeNotification), object: nil)
		
		return true
	}

	func loadProfile(with url: URL) -> TTTProfile {
		var profile = TTTProfile.profileWithContentsOf(url)
		if profile == nil {
			profile = TTTProfile()
		}
		
		return profile!
	}
	
	func updateTintColor() {
		if self.profile.icon == .X {
			self.window?.tintColor = UIColor(hue: 0.0, saturation: 1.0, brightness: 1.0, alpha: 1.0)
		}
		else {
			self.window?.tintColor = UIColor(hue: 1.0 / 3.0, saturation: 1.0, brightness: 0.8, alpha: 1.0)
		}
	}
	
	@objc func iconDidChange(_ notification: Notification) {
		self.updateTintColor()
	}

}

