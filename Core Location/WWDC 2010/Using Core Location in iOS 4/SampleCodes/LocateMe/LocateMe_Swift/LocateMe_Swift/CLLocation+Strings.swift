//
//  CLLocation+Strings.swift
//  LocateMe_Swift
//
//  Created by Seyed Samad Gholamzadeh on 3/7/19.
//  Copyright © 2019 Seyed Samad Gholamzadeh. All rights reserved.
//

import Foundation
import CoreLocation

extension CLLocation {
	
	var localizedCoordinateString: String {
		if self.horizontalAccuracy < 0 {
			return NSLocalizedString("DataUnavailable", comment: "DataUnavailable");
		}
		let latString = (self.coordinate.latitude < 0) ? NSLocalizedString("South", comment: "South") : NSLocalizedString("North", comment: "North")
		let lonString = (self.coordinate.longitude < 0) ? NSLocalizedString("West", comment: "West") : NSLocalizedString("East", comment: "East")
		return String(format: NSLocalizedString("LatLongFormat", comment: "LatLongFormat"), fabs(self.coordinate.latitude), latString, fabs(self.coordinate.longitude), lonString)
	}
	
	var localizedAltitudeString: String {
		if self.verticalAccuracy < 0 {
			return NSLocalizedString("DataUnavailable", comment: "DataUnavailable")
		}
		let seaLevelString = self.altitude < 0 ? NSLocalizedString("BelowSeaLevel",comment: "BelowSeaLevel") : NSLocalizedString("AboveSeaLevel", comment: "AboveSeaLevel")
			return String(format: NSLocalizedString("AltitudeFormat", comment: "AltitudeFormat"),  fabs(self.altitude), seaLevelString)
	}
	
	var localizedHorizontalAccuracyString: String {
		if (self.horizontalAccuracy < 0) {
			return NSLocalizedString("DataUnavailable", comment: "DataUnavailable");
		}
		return String(format: NSLocalizedString("AccuracyFormat", comment: "AccuracyFormat"), self.horizontalAccuracy)
	}
	
	var localizedVerticalAccuracyString: String {
		if self.verticalAccuracy < 0 {
			return NSLocalizedString("DataUnavailable", comment: "DataUnavailable")
		}
		return String(format: NSLocalizedString("AccuracyFormat", comment: "AccuracyFormat"), self.verticalAccuracy)
	}
	
	var localizedCourseString: String {
		if self.course < 0 {
			return NSLocalizedString("DataUnavailable", comment: "DataUnavailable");
		}
		return String(format: NSLocalizedString("CourseFormat", comment: "CourseFormat"), self.course)
	}
	
	var localizedSpeedString: String {
		if self.speed < 0 {
			return NSLocalizedString("DataUnavailable", comment: "DataUnavailable")
		}
		
		return String(format:NSLocalizedString("SpeedFormat", comment: "SpeedFormat"), self.speed)
	}
	
}
