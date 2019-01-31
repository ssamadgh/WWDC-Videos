/*
Copyright (C) 2017 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
Application delegate that sets up a tab bar controller with two view controllers -- a navigation controller that in turn loads a table view controller to manage a list of recipes, and a unit converter view controller.
*/

import UIKit
import CoreData

@UIApplicationMain
class RecipesAppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?

	
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		// Override point for customization after application launch.
		
		if let tabbBarController = self.window?.rootViewController as? UITabBarController {
			if let navController = tabbBarController.viewControllers?.first as? UINavigationController {
				if let recipeListTVC = navController.topViewController as? RecipeListTableViewController {
					recipeListTVC.managedObjectContext = self.managedObjectContext
				}
			}
		}
		
		return true
	}


	func applicationWillTerminate(_ application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
		
		if self.managedObjectContext.hasChanges {
			try! self.managedObjectContext.save()
		}
		
	}
	
	
	//MARK: - Core Data stack
	
	/**
	Returns the managed object context for the application.
	If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
	*/
	lazy var managedObjectContext: NSManagedObjectContext = {
		let coordinatior = self.persistentStoreCoordinator
		let moc = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
		moc.persistentStoreCoordinator = coordinatior
		return moc
	}()
	
	/**
	Returns the managed object model for the application.
	If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
	*/
	lazy var managedObjectModel: NSManagedObjectModel = {
		let modelURL = Bundle.main.url(forResource: "Recipes_Swift", withExtension: "momd")
		let mom = NSManagedObjectModel(contentsOf: modelURL!)
		return mom!
	}()
	
	/**
	Returns the URL to the application's documents directory.
	*/
	var applicationDocumentsDirectory: URL {
		return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
	}
	
	/**
	Returns the persistent store coordinator for the application.
	If the coordinator doesn't already exist, it is created and the application's store added to it.
	*/
	lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
		// Copy the default store (with a pre-populated data) into our Documents folder.
		//
		let documentsStoreURL = self.applicationDocumentsDirectory.appendingPathComponent("Recipes.sqlite")
		
		// if the expected store doesn't exist, copy the default store
		if !FileManager.default.fileExists(atPath: documentsStoreURL.path) {
			if let defaultStoreURL = Bundle.main.url(forResource: "Recipes", withExtension: "sqlite") {
				try! FileManager.default.copyItem(at: defaultStoreURL, to: documentsStoreURL)
			}
		}
		
		let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
		
		// Add the default store to our coordinator.
		
		do {
			try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: documentsStoreURL, options:  [NSMigratePersistentStoresAutomaticallyOption: true,
																																	NSInferMappingModelAutomaticallyOption: true])
			
//			// setup and add the user's store to our coordinator
//			let userStoreURL = self.applicationDocumentsDirectory.appendingPathComponent("UserRecipes.sqlite")
//			print(userStoreURL)
//			print(documentsStoreURL)
//			try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: userStoreURL, options: [NSMigratePersistentStoresAutomaticallyOption: true,
//																															  NSInferMappingModelAutomaticallyOption: true])

		}
		catch {
			print("persistentStore Coordinator Error", error)
		}
		
		return coordinator
		
	}()


}

