//
//  UserViewModel.swift
//  SmoothScrolling
//
//  Created by Andrea Prearo on 8/10/16.
//  Copyright © 2016 Andrea Prearo. All rights reserved.
//

import UIKit
import ModelAssistant

struct UserViewModel: MAEntity & Hashable {
	
	var uniqueValue: Int {
		return id
	}
	
	subscript(key: String) -> String? {
		return nil
	}
	
	mutating func update(with newFetechedEntity: MAEntity) {
		
	}
	
	let id: Int
    let avatarUrl: String
    let username: String
    let role: Role
    let roleText: String
	var image: UIImage?
	
	var needsToDownloadImage: Bool {
		return image == nil
	}
	
	init(user: User, id: Int = 0) {
        // Avatar
        avatarUrl = user.avatarUrl
        
        // Username
        username = user.username
		
        self.id = id
		
        // Role
        role = user.role
        roleText = user.role.rawValue
    }
	
}


extension String {
	
	func convertLettersToNum() -> Int {
		
		
		let array = Array(self.lowercased())
		let numArray: [String] = array.map { "\($0.numberInAlphabet())" }
		let joined = numArray.joined()
		return Int(joined)!
	}
}

extension Character {
	
	func numberInAlphabet() -> Int {
		
		guard Int(String(self)) == nil else {
			return Int(String(self))!
		}
		
		let alphabetsArray = Array("abcdefghijklmnopqrstuvwxyz")
		
		guard let index = alphabetsArray.firstIndex(of: self) else {
			return 0
		}
		
		return index + 1
		
	}
}
