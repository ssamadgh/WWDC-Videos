//
//  ReminderCircleView.swift
//  Reminders_Swift
//
//  Created by Seyed Samad Gholamzadeh on 3/18/19.
//  Copyright © 2019 Seyed Samad Gholamzadeh. All rights reserved.
//
/*
Abstract:
Overlay view that draws a circle
*/

import Foundation
import MapKit

class ReminderCircleRenderer: MKOverlayPathRenderer {
	
	var reminder: ReminderAnnotation {
		return (self.overlay as! ReminderAnnotation)
	}
	
	override init(overlay: MKOverlay) {
		assertionFailure("-initWithReminder: is the designated initializer")
		super.init(overlay: overlay)
	}
	
	init(reminder: ReminderAnnotation) {
		super.init(overlay: reminder)
		self.reminder.addObserver(self, forKeyPath: "coordinate", options: NSKeyValueObservingOptions.initial, context: nil)
		self.reminder.addObserver(self, forKeyPath: "radius", options: NSKeyValueObservingOptions.initial, context: nil)
	}
	
	deinit {
		self.reminder.removeObserver(self, forKeyPath: "coordinate")
		self.reminder.removeObserver(self, forKeyPath: "radius")
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func createPath() {
		let path = CGMutablePath()
		let center = self.reminder.coordinate
		let centerPoint = self.point(for: MKMapPoint(center))
		let radius: CGFloat = CGFloat(MKMapPointsPerMeterAtLatitude(center.latitude) * self.reminder.radius)
		path.addArc(center: centerPoint, radius: radius, startAngle: 0, endAngle: .pi * 2, clockwise: true)
		self.path = path
	}
	
	override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
		self.invalidatePath()
	}
	
}
