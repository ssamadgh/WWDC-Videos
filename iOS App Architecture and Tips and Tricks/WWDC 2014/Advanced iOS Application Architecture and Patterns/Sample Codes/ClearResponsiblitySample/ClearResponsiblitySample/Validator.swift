
import Foundation

public protocol Validable {
	
	var identifier: String? { get set}
	
	var text: String? { get set}
	
	func isInvalid(with error: ValidatorError)
}

public enum ValidatorErrorType {
	
	case isEmpty
	case isInvalid
	
}

public struct ValidatorError: Error {
	
	public var type: ValidatorErrorType
	public var description: String?
}


public protocol Validator {
	
	func validate(completion: ((_ error: ValidatorError?) -> Void)?) -> Bool
}

struct GroupValidator: Validator {
	
	var validators: [Validator]
	
	init(_ validators: [Validator]) {
		self.validators = validators
	}
	
	func validate(completion: ((ValidatorError?) -> Void)?) -> Bool {
		
		var isValid: Set<Bool> = []
		
		var errors: [ValidatorError] = []
		
		defer {
			completion?(errors.first)
		}
		
		self.validators.forEach { (validator) in
			
			let partIsValid = validator.validate { (error) in
				if error != nil {
					errors.append(error!)
				}
			}
			
			isValid.insert(partIsValid)
		}
		
		return !isValid.contains(false)
		
	}
	
}
