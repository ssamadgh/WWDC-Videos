/*
 Copyright (C) 2016 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 Creates the watch complications displaying the current lat/lon and/or US state information.
 */

import WatchKit

/**
    The `PotlocComplicationController` is responsible for communicating between
    the "Complication" interface and the `CLLocationManager`. This interface controller exemplifies
    how to create a watch complication using location data obtained from CLLocationManager.
     
    At first, the complications contain placeholder values defined in 'getLocalizableSampleTemplate()'.
    Subsequent location updates occur at each call of 'getCurrentTimelineEntry()'. The complications
    periodically update with real location data with CLLocationManager's `requestLocation(_:)` method.
 */
class PotlocComplicationController: NSObject, CLKComplicationDataSource, CLLocationManagerDelegate {
    // MARK: - Timeline Configuration
    
    var lat: String = "0.00"; // The current latitude
    var lon: String = "0.00"; // The current longitude
    var state: String = "NI"; // The current US state (default is Null Island)
    
    var manager: CLLocationManager = CLLocationManager()
    
    //We don't support time travel
    func getSupportedTimeTravelDirections(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimeTravelDirections) -> Swift.Void) {
        handler([])
    }
    
    func getTimelineStartDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Swift.Void) {
        handler(nil)
    }
    
    func getTimelineEndDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Swift.Void) {
        handler(nil)
    }
    
    func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Swift.Void) {
        handler(.showOnLockScreen)
    }
    
    // MARK: - Timeline Population
    
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Swift.Void) {
        // Call the handler with the current timeline entry
        guard let template = self.complicationTemplateForData(complication: complication,state: self.state,lat: self.lat,lon: self.lon) else {
            handler(nil)
            return;
        }
        let entry: CLKComplicationTimelineEntry = CLKComplicationTimelineEntry.init(date: NSDate() as Date, complicationTemplate: template)
        handler(entry)
    }
    
    func getTimelineEntries(for complication: CLKComplication, before date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Swift.Void) {
        // Call the handler with the timeline entries prior to the given date
        handler(nil)
    }
    
    func getTimelineEntries(for complication: CLKComplication, after date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Swift.Void) {
        // Call the handler with the timeline entries after to the given date
        handler(nil)
    }

    // MARK: - Placeholder Templates
    
    func getLocalizableSampleTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Swift.Void) {
        handler(self.complicationTemplateForData(complication: complication,state: "CA",lat: "37.122",lon: "-122.545"))
    }
  
    // MARK: - Location Specific Methods
    
    func getNextRequestedUpdateDate(handler: @escaping (Date?) -> Swift.Void) {
        // Set the update interval to 30 minutes
        handler(NSDate(timeIntervalSinceNow: 60*30) as Date)
    }
    
    func requestedUpdateDidBegin(){
        manager.delegate = self
        manager.requestLocation()
        let server=CLKComplicationServer.sharedInstance()
        for comp in (server.activeComplications)! {
            server.reloadTimeline(for: comp)
        }
    }
    
    func requestedUpdateBudgetExhausted(){
        manager.requestLocation()
        let server=CLKComplicationServer.sharedInstance()
        for comp in (server.activeComplications)! {
            server.reloadTimeline(for: comp)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.lat = String(format:"%.4f", (locations.last?.coordinate.latitude)!)
        self.lon = String(format:"%.4f", (locations.last?.coordinate.longitude)!)
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(locations.last!, completionHandler: { (placemarks, error) -> Void in
            guard let placeMark: CLPlacemark = placemarks?[0] else {
                return
            }
            guard let state = placeMark.administrativeArea as String! else {
                return
            }
            self.state = state
        })
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
        
    // Helper function to define a CLKComplicationTemplate
    func complicationTemplateForData(complication: CLKComplication, state: String, lat: String, lon: String) -> CLKComplicationTemplate? {
        var final_template: CLKComplicationTemplate? = nil
        switch complication.family {
        case .modularSmall:
            let template = CLKComplicationTemplateModularSmallRingText()
            template.textProvider = CLKSimpleTextProvider(text: state)
            template.ringStyle = CLKComplicationRingStyle.closed
            template.fillFraction = 0.0
            final_template = template
        case .modularLarge:
            let template = CLKComplicationTemplateModularLargeStandardBody()
            template.headerTextProvider = CLKSimpleTextProvider(text: state)
            template.body1TextProvider = CLKSimpleTextProvider(text: "Lat: "+lat, shortText: lat)
            template.body2TextProvider = CLKSimpleTextProvider(text: "Lon: "+lon, shortText: lon)
            final_template = template
        case .utilitarianSmall:
            let template = CLKComplicationTemplateUtilitarianSmallFlat()
            template.textProvider = CLKSimpleTextProvider(text: state)
            final_template = template
        case .utilitarianSmallFlat:
            let template = CLKComplicationTemplateUtilitarianSmallFlat()
            template.textProvider = CLKSimpleTextProvider(text: state)
            final_template = template
        case .utilitarianLarge:
            let template = CLKComplicationTemplateUtilitarianLargeFlat()
            let latlon = String(format: "Lat: "+lat+" Lon:"+lon)
            template.textProvider = CLKSimpleTextProvider(text: latlon, shortText: lat+lon)
            final_template = template
        case .circularSmall:
            let template = CLKComplicationTemplateCircularSmallRingText()
            template.textProvider = CLKSimpleTextProvider(text: state)
            template.ringStyle = CLKComplicationRingStyle.closed
            template.fillFraction = 0.0
            final_template = template
        case .extraLarge:
            let template = CLKComplicationTemplateExtraLargeStackText()
            template.line1TextProvider = CLKSimpleTextProvider(text: "Lat: "+lat, shortText: lat)
            template.line2TextProvider = CLKSimpleTextProvider(text: "Lon: "+lon, shortText: lon)
            template.highlightLine2 = true
            final_template = template
        }
        return final_template
    }
}
