/*
Copyright (C) 2016 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

*/

import WatchKit
import Foundation

/**
    The `RequestLocationInterfaceController` is responsible for communicating between
    the "Request" interface and the `LocationModel`. This interface controller exemplifies
    how to call the `CLLocationManager` directly from a WatchKit Extension using 
    the `requestLocation(_:)` method.

    In order to guarantee that the information displayed in the interface is fresh,
    this class uses a 2 second timeout after every location update to reset the
    interface. This is done in order to make the example more clear and to avoid stale
    data polluting the interface.
*/
class RequestLocationInterfaceController: WKInterfaceController, CLLocationManagerDelegate {

    // MARK: Properties

    /**
        When this timer times out, the labels in the interface reset to a default state that does not resemble
        a requestLocation result.
    */
    var interfaceResetTimer = Timer()
    
    /// Location manager to request authorization and location updates.
    let manager = CLLocationManager()
    
    /// Flag indicating whether the manager is requesting the user's location.
    var isRequestingLocation = false
    
    /// Button to request location. Also allows cancelling the location request.
    @IBOutlet var requestLocationButton: WKInterfaceButton!
    
    /// Timer to count down 5 seconds as a visual cue that the interface will reset.
    @IBOutlet var displayTimer: WKInterfaceTimer!
    
    /// Label to display the most recent location's latitude.
    @IBOutlet var latitudeLabel: WKInterfaceLabel!
    
    /// Label to display the most recent location's longitude.
    @IBOutlet var longitudeLabel: WKInterfaceLabel!
    
    /// Label to display an error if the location manager finishes with an error.
    @IBOutlet var errorLabel: WKInterfaceLabel!
    
    // MARK: Localized String Convenience

    var interfaceTitle: String {
        return NSLocalizedString("Request", comment: "Indicates that this interface exemplifies requesting location from the watch")
    }
    
    var requestLocationTitle: String {
        return NSLocalizedString("Request Location", comment: "Button title to indicate that pressing the button will cause the location manager to request location")
    }

    var cancelTitle: String {
        return NSLocalizedString("Cancel", comment: "Cancel the current action")
    }
    
    var deniedText: String {
        return NSLocalizedString("Location authorization denied.", comment: "Text to indicate authorization status is .Denied")
    }
    
    var unexpectedText: String {
        return NSLocalizedString("Unexpected authorization status.", comment: "Text to indicate authorization status is an unexpected value")
    }
    
    var latitudeResetText: String {
        return NSLocalizedString("<latitude reset>", comment: "String indicating that no latitude is shown to the user due to a timer reset")
    }
    
    var longitudeResetText: String {
        return NSLocalizedString("<longitude reset>", comment: "String indicating that no longitude is shown to the user due to a timer reset")
    }
    
    var errorResetText: String {
        return NSLocalizedString("<no error>", comment: "String indicating that no error is shown to the user")
    }
    
    // MARK: Interface Controller
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        self.setTitle(interfaceTitle)
        
        // Remember to set the location manager's delegate.
        manager.delegate = self

        resetInterface()
    }
    
    // MARK: Button Actions
    
    /**
        When the user taps the Request Location button in the interface, this method 
        informs the `LocationModel`'s shared instance to request a location.
    
        If the user is already requesting location, this method will instead cancel
        the request.
    */
    @IBAction func requestLocation() {
        guard !isRequestingLocation else {
            manager.stopUpdatingLocation()
            isRequestingLocation = false
            requestLocationButton.setTitle(requestLocationTitle)
            
            return
        }
        
        let authorizationStatus = CLLocationManager.authorizationStatus()
        
        switch authorizationStatus {
        case .notDetermined:
            isRequestingLocation = true
            requestLocationButton.setTitle(cancelTitle)
            manager.requestWhenInUseAuthorization()
            
        case .authorizedWhenInUse:
            isRequestingLocation = true
            requestLocationButton.setTitle(cancelTitle)
            manager.requestLocation()
            
        case .denied:
            errorLabel.setText(deniedText)
            restartTimers()
            
        default:
            errorLabel.setText(unexpectedText)
            restartTimers()
        }
    }
    
    // MARK: CLLocationManagerDelegate Methods
    
    /**
        When the location manager receives new locations, display the latitude and
        longitude of the latest location and restart the timers.
    */
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard !locations.isEmpty else { return }

        DispatchQueue.main.async {
            let lastLocationCoordinate = locations.last!.coordinate

            self.latitudeLabel.setText(String(lastLocationCoordinate.latitude))
            
            self.longitudeLabel.setText(String(lastLocationCoordinate.longitude))
            
            self.isRequestingLocation = false
            
            self.requestLocationButton.setTitle(self.requestLocationTitle)
            
            self.restartTimers()
        }
    }
    
    /**
        When the location manager receives an error, display the error and restart the timers.
    */
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.errorLabel.setText(String(error.localizedDescription))

            self.isRequestingLocation = false
            
            self.requestLocationButton.setTitle(self.requestLocationTitle)
            
            self.restartTimers()
        }
    }
    
    /**
        Only request location if the authorization status changed to an authorization
        level that permits requesting location.
    */
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        DispatchQueue.main.async {
            guard self.isRequestingLocation else { return }

            switch status {
                case .authorizedWhenInUse:
                    manager.requestLocation()
                    
                case .denied:
                    self.errorLabel.setText(self.deniedText)
                    self.isRequestingLocation = false
                    self.requestLocationButton.setTitle(self.requestLocationTitle)
                    self.restartTimers()
                    
                default:
                    self.errorLabel.setText(self.unexpectedText)
                    self.isRequestingLocation = false
                    self.requestLocationButton.setTitle(self.requestLocationTitle)
                    self.restartTimers()
            }
        }
    }
    
    // MARK: Resetting
    
    /**
        Resets the text labels in the interface to empty labels.
    
        This method is useful for cleaning the interface to ensure that data displayed
        to the user is not stale.
    */
    func resetInterface() {
        DispatchQueue.main.async {
            self.stopDisplayTimer()

            self.latitudeLabel.setText(self.latitudeResetText)
            
            self.longitudeLabel.setText(self.longitudeResetText)
            
            self.errorLabel.setText(self.errorResetText)
        }
    }
    
    /**
        Restarts the Timer and the WKInterface timer by stopping / invalidating
        them, then starting them with a 5 second timeout.
    */
    func restartTimers() {
        stopDisplayTimer()

        interfaceResetTimer.invalidate()
        
        interfaceResetTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(RequestLocationInterfaceController.resetInterface), userInfo: [:], repeats: false)
        
        let fiveSecondDelay = NSDate(timeIntervalSinceNow: 5)
        
        displayTimer.setDate(fiveSecondDelay as Date)
        
        displayTimer.start()
    }
    
    /**
        Stops the display timer.
    */
    func stopDisplayTimer() {
        let now = NSDate()
        displayTimer.setDate(now as Date)

        displayTimer.stop()
    }
}
