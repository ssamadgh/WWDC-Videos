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
					recipeListTVC.managedObjectContext = self.persistentContainer.viewContext
				}
			}
		}
		
		return true
	}


	func applicationWillTerminate(_ application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
			self.saveContext()
	}
	
	
	//MARK: - Core Data stack
	
	/**
	Returns the URL to the application's documents directory.
	*/
	var applicationDocumentsDirectory: URL {
		return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
	}
	
	lazy var persistentContainer: NSPersistentContainer = {
		
		let container = NSPersistentContainer(name: "Recipes_Swift")
		print(NSPersistentContainer.defaultDirectoryURL())
		container.loadPersistentStores() { (description, error) in
			if let error = error {
				fatalError("Failed to load Core Data stack: \(error)")
			}
			else {
				
				// Copy the default store (with a pre-populated data) into our Documents folder.
				//
				let documentsStoreURL = self.applicationDocumentsDirectory.appendingPathComponent("Recipes.sqlite")
				
				// if the expected store doesn't exist, copy the default store
				if !FileManager.default.fileExists(atPath: documentsStoreURL.path) {
					if let defaultStoreURL = Bundle.main.url(forResource: "Recipes", withExtension: "sqlite") {
						try! FileManager.default.copyItem(at: defaultStoreURL, to: documentsStoreURL)
					}
				}
				
				do {
					try container.persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: documentsStoreURL, options:  [NSMigratePersistentStoresAutomaticallyOption: true,
																																			NSInferMappingModelAutomaticallyOption: true])
				}
				catch {
					print("persistentStore Coordinator Error", error)
				}


				
			}
		}
		
		return container
	}()
	
	func saveContext () {
		let context = persistentContainer.viewContext
		if context.hasChanges {
			do {
				try context.save()
			} catch {
				// Replace this implementation with code to handle the error appropriately.
				// fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
				let nserror = error as NSError
				fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
			}
		}
	}



}

