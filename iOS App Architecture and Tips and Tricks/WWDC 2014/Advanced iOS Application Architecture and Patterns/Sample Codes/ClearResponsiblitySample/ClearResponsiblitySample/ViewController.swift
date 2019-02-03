//
//  ViewController.swift
//  ClearResponsiblitySample
//
//  Created by Seyed Samad Gholamzadeh on 1/27/19.
//  Copyright © 2019 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {

	@IBOutlet weak var usernameField: MYTextField!
	@IBOutlet weak var emailTextField: MYTextField!
	@IBOutlet weak var phoneTextField: MYTextField!

	@IBOutlet weak var doneButton: UIButton!
	@IBOutlet weak var alertLabel: UILabel!
	
	var passwordTextField: MYTextField!
	
	var allValid: Bool = false
	var anyNil: Bool = true
	
	override func viewDidLoad() {
		self.usernameField.identifier = "username"
		self.usernameField.delegate = self
		
		self.emailTextField.identifier = "email"
		self.emailTextField.delegate = self

		self.phoneTextField.identifier = "phone"
		self.phoneTextField.delegate = self
//
//		self.passwordTextField = MYTextField()
//		self.passwordTextField.identifier = "password"
	}
	
	func validateFields() {
		let usernameValidator = UsernameValidator(validable: self.usernameField)
		let emailValidator = EmailAddressValidator(validable: self.emailTextField)
		let phoneValidator = PhoneValidator(validable: self.phoneTextField)

		let signUpValidator = GroupValidator([usernameValidator, emailValidator, phoneValidator])
		
		let isValid = signUpValidator.validate { (error) in
			guard let type = error?.type else { return }
			switch type {
			case .isInvalid:
				self.alertLabel.text = error?.description
			case .isEmpty:
				self.alertLabel.text = error?.description
			}
		}
		
		self.doneButton.isEnabled = isValid
		
	}
	
	func textFieldDidBeginEditing(_ textField: UITextField) {
		textField.textColor = .black
		self.alertLabel.text = ""
		self.doneButton.isEnabled = false
	}
	
	func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
		self.validateFields()
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return true
	}
	

}


public class MYTextField: UITextField, Validable {
	
	public var identifier: String?
	
	public func isInvalid(with error: ValidatorError) {
		switch error.type {
		case .isEmpty:
			self.textColor = .black
			
		case .isInvalid:
			self.textColor = .red
			
		}
	}
	
}



struct UsernameValidator: Validator {
	
	let validable: Validable
	
	func validate(completion: ((ValidatorError?) -> Void)?) -> Bool {

		var error: ValidatorError?
		
		defer {
			
			if error != nil {
				self.validable.isInvalid(with: error!)
			}
			
			completion?(error)
		}
		
		guard let username = self.validable.text, !username.isEmpty else {
			let desc = "\(validable.identifier!) is Empty"
			error = ValidatorError(type: .isEmpty, description: desc)
			return false
		}
		
		let regex = try! NSRegularExpression(pattern: "[a-zA-Z0-9_]{6,}", options: [])
		let result = regex.rangeOfFirstMatch(in: username, options: NSRegularExpression.MatchingOptions.anchored, range: NSRange(location: 0, length: username.count))
		
		if result.location == NSNotFound {
			let desc = "\(validable.identifier!) is wrong"
			error = ValidatorError(type: .isInvalid, description: desc)
			return false
		}
		
		return true
	}
	
}

struct EmailAddressValidator: Validator {

	let validable: Validable

	func validate(completion: ((ValidatorError?) -> Void)?) -> Bool {
		
		var error: ValidatorError?
		
		defer {
			
			if error != nil {
				self.validable.isInvalid(with: error!)
			}
			
			completion?(error)
		}

		guard let email = self.validable.text, !email.isEmpty else {
			let desc = "\(validable.identifier!) is Empty"
			error = ValidatorError(type: .isEmpty, description: desc)
			return false
		}

		if !email.contains("@") {
			let desc = "\(validable.identifier!) is wrong"
			error = ValidatorError(type: .isInvalid, description: desc)
			return false
		}
		
		return true
	}

}

struct PhoneValidator: Validator {
	
	let validable: Validable
	
	func validate(completion: ((ValidatorError?) -> Void)?) -> Bool {
		
		var error: ValidatorError?
		
		defer {
			
			if error != nil {
				self.validable.isInvalid(with: error!)
			}
			
			completion?(error)
		}
		
		guard let phoneNum = self.validable.text, !phoneNum.isEmpty else {
			let desc = "\(validable.identifier!) is Empty"
			error = ValidatorError(type: .isEmpty, description: desc)
			return false
		}
		
		if Int(phoneNum) == nil {
			let desc = "\(validable.identifier!) is wrong"
			error = ValidatorError(type: .isInvalid, description: desc)
			return false
		}
		
		return true
	}
	
}

//class PasswordValidator: Validator {
//
//}
//
//class SetPasswordValidator: Validator {
//
//	let firstPasswordValidator = PasswordValidator()
//	let secondPasswordValidator = PasswordValidator()
//}
//
//
//class SignUpValidator: Validator {
//	let usernameValidator = UsernameValidator()
//	let setPasswordValidator = SetPasswordValidator()
//	let emailAddressValidator = EmailAddressValidator()
//
//}

