/*
Copyright (C) 2014 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:

The model object that represents a conversation.

*/

import Foundation

class AAPLConversation: NSObject {
	
	var name: String!
	var photos: [AAPLPhoto]!
	
	static func conversationWithDictionary(_ dictionary: [String : Any]) -> AAPLConversation {
		
		let conversation = AAPLConversation()
		conversation.name = dictionary["name"] as! String
		let photoValues = dictionary["photos"] as! [[String : Any]]
		var photos: [AAPLPhoto] = []
		
		for photoValue in photoValues {
			let photo = AAPLPhoto.photoWithDictionary(photoValue)
			photos.append(photo)
		}
		
		conversation.photos = photos
		return conversation
	}
}
