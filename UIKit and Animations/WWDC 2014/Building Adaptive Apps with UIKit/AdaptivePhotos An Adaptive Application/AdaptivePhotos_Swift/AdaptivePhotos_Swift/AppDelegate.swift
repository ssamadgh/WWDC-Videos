//
//  AppDelegate.swift
//  AdaptivePhotos_Swift
//
//  Created by Seyed Samad Gholamzadeh on 7/23/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

	var window: UIWindow?


	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		// Override point for customization after application launch.
		
		let url = Bundle.main.url(forResource: "User", withExtension: "plist")!
		let userDictionary = NSDictionary(contentsOf: url)!
		let user = AAPLUser.userWithDictionary(dictionary: userDictionary as! [String : Any])
		
		self.window = UIWindow(frame: UIScreen.main.bounds)
		
		let controller = UISplitViewController()
		controller.delegate = self
		let master = AAPLListTableViewController()
		master.user = user
		
		let masterNav = UINavigationController(rootViewController: master)
		
		let detail = AAPLEmptyViewController()
		
		controller.viewControllers = [masterNav, detail]
		controller.preferredDisplayMode = .allVisible
		let traitController = AAPLTraitOverrideViewController()
		traitController.viewController = controller
		self.window?.rootViewController = traitController
		self.window?.makeKeyAndVisible()
		
		return true
	}

	//MARK: - Split View Controller
	func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {

		if let photo = secondaryViewController.aapl_containedPhoto {
			// Before collapsing, remove any view controllers on our stack that don't match the photo we are about to merge on
			if primaryViewController is UINavigationController {
				var viewControllers: [UIViewController] = []
				for controller in (primaryViewController as! UINavigationController).viewControllers {
					if controller.aapl_contains(photo) {
						viewControllers.append(controller)
					}
				}
				(primaryViewController as! UINavigationController).viewControllers = viewControllers
			}
			
			return false
		}
		else {
			// If our secondary controller doesn't show a photo, do the collapse ourself by doing nothing
			return true
		}
	}
	
	func splitViewController(_ splitViewController: UISplitViewController, separateSecondaryFrom primaryViewController: UIViewController) -> UIViewController? {
		if primaryViewController is UINavigationController {
			for controller in (primaryViewController as! UINavigationController).viewControllers {
				if controller.aapl_containedPhoto != nil {
					// Do the standard behavior if we have a photo
					return nil
				}
			}
		}
		// If there's no content on the navigation stack, make an empty view controller for the detail side
		return AAPLEmptyViewController()
	}
	


}

