//
//  AppDelegate.swift
//  SongMap_Swift
//
//  Created by Seyed Samad Gholamzadeh on 3/14/19.
//  Copyright © 2019 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData
import MediaPlayer

@UIApplicationMain
class SongMapAppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {
	
	@IBOutlet var window: UIWindow?
	var locationManager: CLLocationManager!
	@IBOutlet var mainViewController: MainViewController!
	
	override func awakeFromNib() {
		super.awakeFromNib()
		self.configureCoreLocationAndContext()
	}
	
	func configureCoreLocationAndContext() {
		if !CLLocationManager.significantLocationChangeMonitoringAvailable() {
			
			let alert = UIAlertController(title: "SongMap cannot track your location on this device", message: "The application will only display existing data restored from another device.", preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
			self.mainViewController.present(alert, animated: true, completion: nil)
		}
		else {
			self.locationManager = CLLocationManager()
			self.locationManager.delegate = self
			
			self.defaultsDidChange(nil) // load preferences from disk
			NotificationCenter.default.addObserver(self, selector: #selector(defaultsDidChange(_:)), name: UserDefaults.didChangeNotification, object: nil)
		}
		
		mainViewController.context = self.managedObjectContext
	}
	
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		// Override point for customization after application launch.
		// Add the main view controller's view to the window and display.
		
		// Your code should check application.applicationState and, if launched in the background, defer loading the UI.
		
		if let location = launchOptions?[.location] as? NSNumber,
			location == NSNumber(booleanLiteral: true) {
			self.configureCoreLocationAndContext()
		}
		
		window?.rootViewController = self.mainViewController
		window?.makeKeyAndVisible()
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
	
	/**
	applicationWillTerminate: saves changes in the application's managed object context before the application terminates.
	*/
	func applicationWillTerminate(_ application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
		if self.managedObjectContext.hasChanges {
			do {
				try self.managedObjectContext.save()
			}
			catch {
				/*
				Replace this implementation with code to handle the error appropriately.
				
				abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
				*/
				print("Unresolved error \(error.localizedDescription)")
				abort()
				
			}
		}
	}
	
	//MARK: - Core Data stack
	
	/**
	Returns the managed object context for the application.
	If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
	*/
	lazy var managedObjectContext: NSManagedObjectContext = {
		let coordinator = self.persistentStoreCoordinator
		
		var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
		managedObjectContext.persistentStoreCoordinator = coordinator
		return managedObjectContext
	}()
	
	lazy var managedObjectModel: NSManagedObjectModel = {
		let modelURL = Bundle.main.url(forResource: "SongMap", withExtension: "momd")!
		let model = NSManagedObjectModel(contentsOf: modelURL)!
		return model
	}()
	
	lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
		let storeUrl = self.applicationDocumentsDirectory.appendingPathComponent("SongMap.sqlite")
		print(storeUrl.path)
		let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
		
		do {
			try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeUrl, options: nil)
		}
		catch {
			/*
			Replace this implementation with code to handle the error appropriately.
			
			abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
			
			Typical reasons for an error here include:
			* The persistent store is not accessible;
			* The schema for the persistent store is incompatible with current managed object model.
			Check the error message to determine what the actual problem was.
			
			
			If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
			
			If you encounter schema incompatibility errors during development, you can reduce their frequency by:
			* Simply deleting the existing store:
			[[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
			
			* Performing automatic lightweight migration by passing the following dictionary as the options parameter:
			[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
			
			Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
			
			*/
			print("Unresolved error \(error.localizedDescription)")
			abort()
		}
		
		return coordinator
	}()
	
	//MARK: - Application's Documents directory
	/**
	Returns the path to the application's Documents directory.
	*/
	var applicationDocumentsDirectory: URL {
		return FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).last!
	}
	
	//MARK: - Memory management
	func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
		/*
		Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
		*/
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
	
	//MARK: - CLLocationManagerDelegate
	
	func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
		switch status {
		case .restricted, .denied:
			disableMyLocationBasedFeatures()
			break
			
		case .authorizedWhenInUse:
			enableMyWhenInUseFeatures()
			break
			
		case .authorizedAlways:
			enableMyWhenInUseFeatures()
			
		case .notDetermined:
			break
		}
	}
	
	/*
	*  locationManager:didUpdateToLocation:fromLocation:
	*
	*  Discussion:
	*    Invoked when a new location is available. oldLocation may be nil if there is no previous location
	*    available.
	*/
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		let player = MPMusicPlayerController.systemMusicPlayer
		
		print(player.nowPlayingItem?.title)
		guard
			let song = player.nowPlayingItem,
			let newLocation = locations.last
			else { return }
		
		_ = SongLocation.insert(song, location: newLocation, in: self.managedObjectContext)
		
		do {
			try self.managedObjectContext.save()
			
		} catch {
			//error
			print("Unresolved error \(error.localizedDescription)")
		}
		
	}
	
	/*
	*  locationManager:didFailWithError:
	*
	*  Discussion:
	*    Invoked when an error has occurred. Error types are defined in "CLError.h".
	*/
	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		// Your code should handle location manager errors here
		print("Location error is \(error.localizedDescription)")
	}
	
	//MARK: - Other
	
	@objc func defaultsDidChange(_ notification: Notification?) {
		UserDefaults.standard.synchronize()
		let isMonitoring = UserDefaults.standard.bool(forKey: monitorLocationKey)
		print("SongMap is monitoring location: \(isMonitoring ? "YES" : "NO")")
		
		if isMonitoring {
			enableBasicLocationServices()
		} else {
			disableMyLocationBasedFeatures()
		}
	}
	
	
	func enableBasicLocationServices() {
		
		switch CLLocationManager.authorizationStatus() {
		case .notDetermined, .authorizedWhenInUse:
			// Request when-in-use authorization initially
			locationManager.requestAlwaysAuthorization()
			break
			
		case .restricted, .denied:
			// Disable location features
			disableMyLocationBasedFeatures()
			break
			
		case .authorizedAlways:
			// Enable location features
			enableMyWhenInUseFeatures()
			break
		}
	}
	
	
	func enableMyWhenInUseFeatures() {
//		self.locationManager.startUpdatingLocation()
		self.locationManager.startMonitoringSignificantLocationChanges()
		self.locationManager.allowsBackgroundLocationUpdates = true

	}
	
	func disableMyLocationBasedFeatures() {
//		self.locationManager.stopUpdatingLocation()
		self.locationManager.stopMonitoringSignificantLocationChanges()
	}

	
}

