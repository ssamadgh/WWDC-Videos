//
//  ViewController.swift
//  KeyChain_SampleCode
//
//  Created by Seyed Samad Gholamzadeh on 12/4/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

	struct Credentials {
		var username: String
		var password: String
	}
	
	
	enum KeychainError: Error {
		case noPassword
		case unexpectedPasswordData
		case unhandledError(status: OSStatus)
	}
	
	static let server = "www.example.com"

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		
		let credentials = Credentials(username: "samad", password: "samadgh")
		
		
		let account = credentials.username
		let password = credentials.password.data(using: String.Encoding.utf8)!
		
		do {
			
			if !self.searchQuery(username: account) {
				
				let query: [String: Any] = [
					kSecClass as String: kSecClassGenericPassword,
					kSecAttrAccount as String: account,
//									kSecAttrServer as String: server,
					kSecValueData as String: password
				]
				
				
				try self.addPass(for: query)
			}
			
		} catch {
			print(error)
		}
		
		
	}
	
	func addPass(for query: [String: Any]) throws {
		let status = SecItemAdd(query as CFDictionary, nil)
		guard status == errSecSuccess else { throw KeychainError.unhandledError(status: status) }

	}

	func searchQuery(username: String) -> Bool {
		let query: [String: Any] = [
									kSecClass as String: kSecClassGenericPassword,
									kSecAttrAccount as String: username,
//									kSecAttrServer as String: server,
									kSecMatchLimit as String: kSecMatchLimitOne,
									kSecReturnAttributes as String: true,
									kSecReturnData as String: true
		]
		
		var item: CFTypeRef?
		let status = SecItemCopyMatching(query as CFDictionary, &item)
		guard status != errSecItemNotFound else {
			let error = KeychainError.noPassword
			print(error)
			return false
		}
		
		guard status == errSecSuccess else {
			let error = KeychainError.unhandledError(status: status)
			print(error)
			return false
		}
		
		guard let existingItem = item as? [String : Any],
			let passwordData = existingItem[kSecValueData as String] as? Data,
			let password = String(data: passwordData, encoding: String.Encoding.utf8),
			let account = existingItem[kSecAttrAccount as String] as? String
			else {
				let error = KeychainError.unexpectedPasswordData
				print(error)
				return false
		}
		
		let credentials = Credentials(username: account, password: password)
		print("username is \(credentials.username)")
		print("password is \(credentials.password)")
		return credentials.password == "samadgh"
	}

}


