/*
 Copyright (C) 2018 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 Implements the UI of a calculator. Calls the Calculator class to implement the
         associated operation when pressing a character in the calculator.
*/

import Cocoa
import CalculatorKit

class CalcViewController: NSViewController {
    // MARK: - Properties
    
    @IBOutlet var display: NSTextField!
    var calculator = Calculator()
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
     // MARK: - Handle Pressed Character
    
    @IBAction func press(_ sender: NSButton) {
        do {
            try calculator.input(sender.title)
            display.stringValue = calculator.displayValue
        } catch let error {
            print("\(error.localizedDescription)")
        }
    }
}
