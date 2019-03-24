//
//  ReminderAnnotation.swift
//  Reminders_Swift
//
//  Created by Seyed Samad Gholamzadeh on 3/18/19.
//  Copyright © 2019 Seyed Samad Gholamzadeh. All rights reserved.
//
/*
Abstract:
ReminderAnnotation implements MKOverlay protocol and is used as both an annotation and an overlay
*/


import Foundation
import CoreLocation
import MapKit

class ReminderAnnotation: NSObject, MKOverlay {
	
	var boundingMapRect: MKMapRect {
		// the overlay can move and grow based on user interaction, thus our bounds are potentially limitless
		// be aware that this has performance implications
		return MKMapRect.world
	}
	
	var title: String?
	var coordinate: CLLocationCoordinate2D
	var radius: CLLocationDistance
	
	init(title: String, coordinate: CLLocationCoordinate2D, radius: CLLocationDistance) {
		self.coordinate = coordinate
		self.radius = radius
		super.init()
		self.title = title
	}
	
//	convenience init(region: CLRegion) {
//		self.init(title: region.identifier, coordinate: (region as! CLCircularRegion).center, radius: (region as! CLCircularRegion).radius)
//	}
	
	convenience init(region: CLCircularRegion) {
		self.init(title: region.identifier, coordinate: region.center, radius: region.radius)
	}
	
	static func reminder(with region: CLCircularRegion) -> ReminderAnnotation {
		return ReminderAnnotation(region: region)
	}
	
	static func reminder(with coordinate: CLLocationCoordinate2D) -> ReminderAnnotation {
		return ReminderAnnotation(title: "New Reminder", coordinate: coordinate, radius: RegionManager.shared.minDistance)
	}
	
	var region: CLCircularRegion {
		get {
			let region = CLCircularRegion(center: self.coordinate, radius: self.radius, identifier: self.title ?? "")
			return region
		}
		
		set {
			self.title = newValue.identifier;
			self.coordinate = newValue.center;
			self.radius = newValue.radius;
		}
	}
	
	

}
