
//
//  TTTMessageServer.swift
//  TicTacToeApp_Swift
//
//  Created by Seyed Samad Gholamzadeh on 7/9/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

let TTTMessageServerDidAddMessagesNotification = "TTTMessageServerDidAddMessagesNotification"
let TTTMessageServerAddedMessageIndexesUserInfoKey = "TTTMessageServerAddedMessageIndexesUserInfoKey"

class TTTMessageServer: NSObject {

	var messages: [TTTMessage]!
	var favoriteMessages: [TTTMessage]!
	
	static let shared: TTTMessageServer = {
		let server = TTTMessageServer()
		try? server.readMessages()
		return server
	}()
	
	var messageURL: URL? {
		do {
			var url = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
			url.appendPathComponent("Messages.ttt")
			return url
		}
		catch {
			return nil
		}
	}
	
	var numberOfMessages: Int {
		return self.messages?.count ?? 0
	}
	
	func readMessages() throws {
		let data = try Data(contentsOf: self.messageURL!)
		self.messages = NSKeyedUnarchiver.unarchiveObject(with: data) as! [TTTMessage]
	}
	
	func writeMessages() throws {
		let data = NSKeyedArchiver.archivedData(withRootObject: self.messages)
		try data.write(to: self.messageURL!, options: Data.WritingOptions.atomic)
	}
	
	func message(at index: Int) -> TTTMessage {
		return self.messages[index]
	}
	
	func add(_ message: TTTMessage) {
		if self.messages == nil {
			self.messages = []
		}
		
		let messageIndex: Int = 0
		self.messages.insert(message, at: messageIndex)
		let userInfo = [TTTMessageServerAddedMessageIndexesUserInfoKey: [messageIndex]]
		NotificationCenter.default.post(name: NSNotification.Name(rawValue: TTTMessageServerDidAddMessagesNotification), object: self, userInfo: userInfo)
		do {
			try self.writeMessages()
		}
		catch {
			print(error.localizedDescription)
		}
	}
	
	func isFavorite(_ message: TTTMessage) -> Bool {
		return self.favoriteMessages?.contains(message) ?? false
	}
	
	func setFavorite(_ favorite: Bool, for message: TTTMessage) {
		
		if favorite {
			if self.favoriteMessages == nil {
				self.favoriteMessages = []
			}
			
			self.favoriteMessages.append(message)
		}
		else {
			self.favoriteMessages.remove(at: self.favoriteMessages.index(of: message)!)
		}
	}

}
