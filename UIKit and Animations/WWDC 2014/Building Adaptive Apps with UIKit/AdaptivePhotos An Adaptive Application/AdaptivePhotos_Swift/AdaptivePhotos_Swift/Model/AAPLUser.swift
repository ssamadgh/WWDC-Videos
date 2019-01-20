/*
	Copyright (C) 2014 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:

The top level model object.

*/


import Foundation


class AAPLUser: NSObject {
	
	var name: String!
	var conversations: [AAPLConversation]!
	var lastPhoto: AAPLPhoto!
	
	static func userWithDictionary(dictionary: [String: Any]) -> AAPLUser {
		let user = AAPLUser()
		user.name = dictionary["name"] as? String
		let conversationDictionaries = dictionary["conversations"] as! [[String : Any]]
		var conversations: [AAPLConversation] = []
		
		for conversationDictionary in conversationDictionaries {
			let conversation = AAPLConversation.conversationWithDictionary(conversationDictionary)
			conversations.append(conversation)
		}
		
		user.conversations = conversations
		
		let lastPhotoDictionary = dictionary["lastPhoto"] as! [String : Any]
		user.lastPhoto = AAPLPhoto.photoWithDictionary(lastPhotoDictionary)
		return user
 	}
}
