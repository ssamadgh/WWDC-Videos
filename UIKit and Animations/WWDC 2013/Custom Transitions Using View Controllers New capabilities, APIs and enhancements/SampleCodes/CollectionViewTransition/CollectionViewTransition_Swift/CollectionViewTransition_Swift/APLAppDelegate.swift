//
//  AppDelegate.swift
//  CollectionViewTransition_Swift
//
//  Created by Seyed Samad Gholamzadeh on 6/29/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

@UIApplicationMain
class APLAppDelegate: UIResponder, UIApplicationDelegate, UINavigationControllerDelegate, APLTransitionManagerDelegate {

	var window: UIWindow?
	var transitionManager: APLTransitionManager!

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		
		let navController = self.window!.rootViewController as! UINavigationController
		// setup our layout and initial collection view
		let stackLayout = APLStackLayout()
		let collectionViewController = APLStackCollectionViewController(collectionViewLayout: stackLayout)
		collectionViewController.title = "Stack Layout"
		navController.navigationBar.isTranslucent = false
		navController.delegate = self
		
		// add the single collection view to our navigation controller
		navController.viewControllers = [collectionViewController]
		
		// we want a light gray for the navigation bar, otherwise it defaults to white
		navController.navigationBar.barTintColor = UIColor.lightGray
		
		// create our "transitioning" object to manage the pinch gesture to transitition between stack and grid layouts
		self.transitionManager = APLTransitionManager(collectionView: collectionViewController.collectionView!)
		self.transitionManager.delegate = self
		
		return true
	}
	
	//MARK: - APLTransitionControllerDelegate
	
	func interactionBegan(at point: CGPoint) {
		let navController = self.window!.rootViewController as! UINavigationController
		
		// Very basic communication between the transition controller and the top view controller
		// It would be easy to add more control, support pop, push or no-op.
		//
		if let viewController = (navController.topViewController as! APLCollectionViewController).nextViewController(at: point) {
			navController.pushViewController(viewController, animated: true)
		}
		else {
			navController.popViewController(animated: true)
		}
	}
	
	//MARK: - UINavigationControllerDelegate

	func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
		// return our own transition manager if the incoming controller matches ours
		if animationController is APLTransitionManager {
			if (animationController as! APLTransitionManager) == self.transitionManager {
				return self.transitionManager
			}
		}
		return nil
	}
	
	func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		var transitionManager: APLTransitionManager? = nil
		
		// make sure we are transitioning from or to a collection view controller, and that interaction is allowed
		if fromVC is UICollectionViewController && toVC is UICollectionViewController && self.transitionManager.hasActiveInteraction {
			self.transitionManager.navigationOperation = operation
			transitionManager = self.transitionManager
		}
		
		return transitionManager
	}
	
	

}

