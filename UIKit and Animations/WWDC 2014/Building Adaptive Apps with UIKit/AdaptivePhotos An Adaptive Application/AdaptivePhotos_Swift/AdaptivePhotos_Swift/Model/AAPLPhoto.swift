/*
Copyright (C) 2014 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:

The model object that represents an individual photo.

*/

import UIKit

class AAPLPhoto: NSObject {
	
	var image: UIImage! {
		let image = UIImage(named: self.imageName)
		return image
	}
	
	var imageName: String!
	var comment: String!
	var rating: Int!
	
	static func photoWithDictionary(_ dictionary: [String : Any]) -> AAPLPhoto {
		let photo = AAPLPhoto()
		photo.imageName = dictionary["imageName"] as? String
		photo.comment = dictionary["comment"] as? String
		photo.rating = dictionary["rating"] as? Int
		return photo
	}
	
}
