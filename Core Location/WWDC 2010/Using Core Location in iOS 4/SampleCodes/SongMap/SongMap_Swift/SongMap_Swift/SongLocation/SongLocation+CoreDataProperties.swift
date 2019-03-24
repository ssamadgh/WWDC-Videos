//
//  SongLocation+CoreDataProperties.swift
//  SongMap_Swift
//
//  Created by Seyed Samad Gholamzadeh on 3/15/19.
//  Copyright © 2019 Seyed Samad Gholamzadeh. All rights reserved.
//
//

/*
Abstract:
 SongLocation is a simple NSManagedObject subclass that provides a few utility methods as well as type checking.
*/

import Foundation
import CoreData
import CoreLocation
import MediaPlayer
import MapKit

extension SongLocation: MKAnnotation {
	

    @NSManaged public var location: CLLocation?
    @NSManaged public var song: MPMediaItem?
    @NSManaged public var timestamp: NSDate?

	// MKAnnotation properties
	public var coordinate: CLLocationCoordinate2D {
		return self.location!.coordinate
	}
	
	public var title: String? {
		guard timestamp != nil else {
			return nil
		}
		let title = DateFormatter.localizedString(from: self.timestamp! as Date, dateStyle: DateFormatter.Style.short, timeStyle: DateFormatter.Style.long)
		return title
	}
	
	public var subtitle: String? {
		var subtitle: String?
		
		if let song = self.song {
			subtitle = song.value(forProperty: MPMediaItemPropertyTitle) as? String
		}
		else {
			subtitle = String(format: "%f, %f\n", self.coordinate.latitude, self.coordinate.longitude)
		}
		return subtitle
	}
	
	@nonobjc public class func fetchRequest() -> NSFetchRequest<SongLocation> {
		return NSFetchRequest<SongLocation>(entityName: "SongLocation")
	}

	// Convenience methods
	class func insert(_ newSong: MPMediaItem, location: CLLocation, in context: NSManagedObjectContext) -> SongLocation {
		let newSonglocation = SongLocation(context: context)
		newSonglocation.location = location
		newSonglocation.song = newSong
		newSonglocation.timestamp = location.timestamp as NSDate
		return newSonglocation
	}
	
	class func fetchRecentLimit(_ limit: Int, in context: NSManagedObjectContext) throws -> [SongLocation] {
		
		let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "SongLocation")
		let sorDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
		fetchRequest.sortDescriptors = sorDescriptors
		fetchRequest.fetchLimit = limit
		let result = try context.fetch(fetchRequest) as! [SongLocation]
		
		return result
	}
	
	func artworkImage(withSize size: CGSize) -> UIImage? {
		guard let artwork = self.song?.value(forProperty: MPMediaItemPropertyArtwork) as? MPMediaItemArtwork else { return nil }
		
		var size = size
		if __CGSizeEqualToSize(size, CGSize.zero) {
			size = artwork.bounds.size
		}
		
		let artworkImage = artwork.image(at: size)
		return artworkImage
	}
	
}

extension SongLocation {
	
	public override var description: String {
		return "title: \(self.subtitle ?? "Unknown")\nlocation:\n latitude: \(self.coordinate.latitude)\nlongitude: \(self.coordinate.longitude)"
	}
	
}

extension SongLocation: CustomReflectable {
	
	public var customMirror: Mirror {
		return Mirror(self, children: ["title" : self.subtitle ?? "Unknown", "latitude" : self.coordinate.latitude, "longitude" : self.coordinate.longitude])
	}
}
