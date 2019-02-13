/*
 Copyright (C) 2018 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 Type used to represent error value thrown for invalid Calculator input.
*/

import Foundation

public enum CalculatorError: Error {
    case invalidCharater
    case multipleCharacters
    case nilInput
}

extension CalculatorError: LocalizedError {
    
    public var errorDescription: String? {
        switch self {
        case .invalidCharater: return NSLocalizedString("Invalid character exception.", comment: "The input is not a number between 0-9, an operator (+, -, *, /), D, C, =, or a period.")
        case .multipleCharacters: return NSLocalizedString("Multiple characters exception.", comment: "The input contains more than one character.")
        case .nilInput: return NSLocalizedString("Nil exception.", comment: "The input is nil.")
        }
    }
}
