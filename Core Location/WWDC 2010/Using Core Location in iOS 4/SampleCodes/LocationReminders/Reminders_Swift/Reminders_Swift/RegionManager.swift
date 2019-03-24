//
//  RegionManager.swift
//  Reminders_Swift
//
//  Created by Seyed Samad Gholamzadeh on 3/19/19.
//  Copyright © 2019 Seyed Samad Gholamzadeh. All rights reserved.
//
/*
Abstract:
Singleton class to manage region monitoring interations with a CLLocationManger
*/

import Foundation
import UIKit
import CoreLocation
import UserNotifications

private let globalRegionManager = RegionManager()

class RegionManager: NSObject, CLLocationManagerDelegate {
	
	class var shared: RegionManager {
		return globalRegionManager
	}
	
	var regions: Set<CLCircularRegion> {
		return self.locationManager.monitoredRegions as? Set<CLCircularRegion> ?? []
	}
	
	var minDistance: CLLocationDistance {
//		return 1000.0 // 1km
		return 500.0 // 0.5km
	}
	
	var maxDistance: CLLocationDistance {
		return self.locationManager.maximumRegionMonitoringDistance
	}
	
	let locationManager: CLLocationManager
	
	override init() {
		self.locationManager = CLLocationManager()
		super.init()
		self.locationManager.delegate = self
		
		if CLLocationManager.authorizationStatus() == .notDetermined || CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
			self.locationManager.requestAlwaysAuthorization()
		}
	}
	
	
	
	func addRegion(_ region: CLRegion) {
		print("startMonitoringForRegion: \(region)")
		self.locationManager.startMonitoring(for: region)
		let enterRegion = region.copy() as! CLRegion
		enterRegion.notifyOnExit = true
		enterRegion.notifyOnEntry = true
		self.scheduleNotificationFor(region: enterRegion, body: "Remember to \(region.identifier)?")
		
//		let exitRegion = region.copy() as! CLRegion
//		enterRegion.notifyOnEntry = true
//		enterRegion.notifyOnExit = true
//		self.scheduleNotificationFor(region: exitRegion, body: "Did you remember to \(region.identifier)?")
	}
	
	func scheduleNotificationFor(region: CLRegion, title: String = "Reminder", body: String) {
		let notificationCenter = UNUserNotificationCenter.current()
		
		notificationCenter.getNotificationSettings { (settings) in
			// Do not schedule notifications if not authorized.
			guard settings.authorizationStatus == .authorized else {
				return
			}
			
			
			
			if settings.alertSetting == .enabled {
				// Schedule an alert-only notification.
				let content = UNMutableNotificationContent()
				content.title = title
				content.body = body
				content.sound = UNNotificationSound.default

				let trigger = UNLocationNotificationTrigger(region: region, repeats: true)
				let identifier = region.identifier
				let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
				
				notificationCenter.add(request, withCompletionHandler: { (error) in
					if error != nil {
						// Handle any errors.
					}
				})
				
			}
		}
	}
	
	func removeNotificationFor(region: CLRegion) {
		let notificationCenter = UNUserNotificationCenter.current()
		notificationCenter.removePendingNotificationRequests(withIdentifiers: [region.identifier])
	}
	
	func removeRegion(_ region: CLRegion) {
		print("stopMonitoringForRegion: \(region)")
		self.locationManager.stopMonitoring(for: region)
		self.removeNotificationFor(region: region)
	}

	//MARK: - CLLocationManagerDelegate
	
	
	/*
	*  locationManager:didEnterRegion:
	*
	*  Discussion:
	*    Invoked when the user enters a monitored region.  This callback will be invoked for every allocated
	*    CLLocationManager instance with a non-nil delegate that implements this method.
	*/

	func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
		print("didEnterRegion: \(region)")
		
		// issue notification the app delegate can respond to
//		(UIApplication.shared.delegate as! RemindersAppDelegate).didEnter(region)
	}
	
	/*
	*  locationManager:didExitRegion:
	*
	*  Discussion:
	*    Invoked when the user exits a monitored region.  This callback will be invoked for every allocated
	*    CLLocationManager instance with a non-nil delegate that implements this method.
	*/

	func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
		print("didExitRegion: \(region)")
		
		// issue notification the app delegate can respond to
//		(UIApplication.shared.delegate as! RemindersAppDelegate).didExit(region)
	}
	
	/*
	*  locationManager:monitoringDidFailForRegion:withError:
	*
	*  Discussion:
	*    Invoked when a region monitoring error has occurred. Error types are defined in "CLError.h".
	*/

	func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
		print("monitoringDidFailForRegion: \(String(describing: region)) withError: \(error.localizedDescription)")
	}
	
}
