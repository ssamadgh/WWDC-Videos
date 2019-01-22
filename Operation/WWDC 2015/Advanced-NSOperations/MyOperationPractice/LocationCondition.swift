/*
  LocationCondition.swift
  MyOperationPractice

  Created by Seyed Samad Gholamzadeh on 7/11/1396 AP.
  Copyright © 1396 AP Seyed Samad Gholamzadeh. All rights reserved.
 
 Abstract:
     This file shows an example of implementing the OperationCondition protocol.
*/

import CoreLocation

/// A condition for verifying access to the user's location.
struct LocationCondition: OperationCondition {
    
    /**
         Declare a new enum instead of using `CLAthurizationStatus`, because that
         enum has more case values than are necessary for our purposes.
    */
    enum Usage {
        case whenInUse
        case always
    }
    
    static let name = "Location"
    static let locationServicesEnabledKey = "CLLocationServicesEnabled"
    static let authorizationStatusKey = "CLAuthorizationStatus"
    static let isMutuallyExclusive = false
    
    let usage: Usage
    
    init(usage: Usage) {
        self.usage = usage
    }
    
    func dependencyForOperation(_ operation: AOperation) -> Foundation.Operation? {
        return LocationPermissionOperation(usage: usage)
    }
    
    func evaluateForOperation(_ operation: AOperation, completion: @escaping (OperationConditionResult) -> Void) {
        let enabled = CLLocationManager.locationServicesEnabled()
        let actual = CLLocationManager.authorizationStatus()
        
        var error: NSError?
        
        // There are several factors to consider when evaluating this condition
        switch (enabled, usage, actual) {
        case (true, _, .authorizedAlways):
            //The service is enabled, and we have "Always" permission -> Condition satisfied.
            break
        case (true, .whenInUse, .authorizedWhenInUse):
            /*
                 The service is enabled, and we have and need "WhenInUse"
                 permission -> condition satisfied
            */
            break
            
        default:
            /*
                 Anything else is an error. Maybe location services are disabled,
                 or maybe we need "Always" permission but only have "WhenInUse"
                 or maybe access has been restricted or denied.
                 or maybe access hasn't been request yet.
             
                 The last case whould happen if this condition were wrapped in a `SilentCondition`.
            */
            error = NSError(code: .conditionFailed, userInfo: [
                OperationConditionKey: type(of: self).name,
                type(of: self).locationServicesEnabledKey: enabled,
                type(of: self).authorizationStatusKey: Int(actual.rawValue)
                ])
        }
        
        if let error = error {
            completion(.failed(error))
        }
        else {
            completion(.satisfied)
        }
    }
}
/**
     A private `AOperation` that will request permission to access the user's location,
     If permission has not already been granted.
*/
private class LocationPermissionOperation: AOperation {
    let usage: LocationCondition.Usage
    var manager: CLLocationManager?
    
    init(usage: LocationCondition.Usage) {
        self.usage = usage
        super.init()
        /*
             This is an operation that potentially presents an alert so it should
             be mutually exclusive with anything else that presents an alert.
        */
        addCondition(AlertPresentation())
    }
    
    override func execute() {
        /*
             Not only do we need to handle the "Not Determined" case, but we also
             need to handle the "upgrade" (.WhenInUse -> .Always) case.
        */
        switch (CLLocationManager.authorizationStatus(), usage) {
        case (.notDetermined, _), (.authorizedWhenInUse, .always):
            DispatchQueue.main.async {
                self.requestPermission()
            }
        default:
            finish()
        }
    }
    
    fileprivate func requestPermission() {
        manager = CLLocationManager()
        manager?.delegate = self
        
        let key: String
        
        switch usage {
        case .whenInUse:
            key = "NSLocationWhenInUseUsageDescription"
            manager?.requestWhenInUseAuthorization()
            
        case .always:
            key = "NSLocationAlwaysUsageDescription"
            manager?.requestAlwaysAuthorization()
        }
        
        // This is helpful when developing the app.
        assert(Bundle.main.object(forInfoDictionaryKey: key) != nil, "Requesting location permission requires the \(key) key in your Info.plist")
    }
    
}

extension LocationPermissionOperation: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
//        assert(status != .notDetermined, "something is wrong cause user must select one option for locatiion accessing and it must not to be .notDetermined")
        
        if manager == self.manager && isExecuting && status != .notDetermined {
            finish()
        }
    }
}
