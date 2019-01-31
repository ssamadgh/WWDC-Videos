/*
Copyright (C) 2017 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
Managed object class for the Quake entity.
*/

import CoreData

class Quake: NSManagedObject {
    // MARK: Properties
    //
    @NSManaged var magnitude: Float
    @NSManaged var placeName: String
    @NSManaged var time: Date
    @NSManaged var longitude: Float
    @NSManaged var latitude: Float
    @NSManaged var depth: Float
    @NSManaged var detailURL: String
    @NSManaged var code: String
    
    // MARK: Convenience Methods
    //
    func update(with quakeDictionary: [String: AnyObject]) throws {
        
        // Only update the quake if all the relevant properties can be accessed.
        //
        guard let properties = quakeDictionary["properties"] as? [String: AnyObject],
                  let newCode = properties["code"] as? String,
                  let newMagnitude = properties["mag"] as? Float,
                  let newPlaceName = properties["place"] as? String,
                  let newDetailURL = properties["detail"] as? String,
                  let newTime = properties["time"] as? Double,
                  let geometry = quakeDictionary["geometry"] as? [String: AnyObject],
                  let coordinates = geometry["coordinates"] as? [Float] else {

                let localizedDescription = NSLocalizedString("Could not interpret data from the earthquakes server.", comment: "")
                
                throw NSError(domain: EarthQuakesErrorDomain, code: 999, userInfo: [
                    NSLocalizedDescriptionKey: localizedDescription])
        }

        code = newCode
        magnitude = newMagnitude
        placeName = newPlaceName
        detailURL = newDetailURL
        time = Date(timeIntervalSince1970: newTime / 1000.0)

        longitude = coordinates[0]
        latitude = coordinates[1]
        depth = coordinates[2]
    }
}
