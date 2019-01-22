/*
  LocationOperation.swift
  MyOperationPractice

  Created by Seyed Samad Gholamzadeh on 7/11/1396 AP.
  Copyright © 1396 AP Seyed Samad Gholamzadeh. All rights reserved.
 
 Abstract:
    This file Shows how to retrieve the user's location with an operation.
*/

import Foundation
import CoreLocation

/**
     `LocationOperation` is an `AOperation` subclass to do a "one-shot" request
     to get the user's current location, with a desired accuracy. This operation will
     prompt for `WhenInUse` location authorization, if the app does not already have it.
*/

class LocationOperation: AOperation {
    // MARK: Properties
    
    fileprivate let accuracy: CLLocationAccuracy
    fileprivate var manager: CLLocationManager?
    fileprivate let handler: (CLLocation) -> Void
    
    // MARK: Intitialization
    
    init(accuracy: CLLocationAccuracy, locationHandler: @escaping (CLLocation) -> Void) {
        self.accuracy = accuracy
        self.handler = locationHandler
        super.init()
        addCondition(LocationCondition(usage: .whenInUse))
        addCondition(MutuallyExclusive<CLLocationManager>())
    }
    
    override func execute() {
        DispatchQueue.main.async {
            /*
                 `CLLocationManager` neeed to be created in a thread with an active
                 run loop, so for simplicity we do this on the main queue.
            */
            let manager = CLLocationManager()
            manager.desiredAccuracy = self.accuracy
            manager.delegate = self
            manager.startUpdatingLocation()
            
            self.manager = manager
        }
    }
    
    override func cancel() {
        DispatchQueue.main.async {
            self.stopLocationUpdates()
            super.cancel()
        }
    }
    
    fileprivate func stopLocationUpdates() {
        manager?.stopUpdatingLocation()
        manager = nil
    }
}

// MARK: CLLocationManagerDelegate
extension LocationOperation: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last, location.horizontalAccuracy <= accuracy else {
            return
        }
        
        stopLocationUpdates()
        handler(location)
        finish()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        stopLocationUpdates()
        finishWithError(error as NSError?)
    }
}
