/*
 Copyright (C) 2018 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 Implements the UI of a calculator. Calls the Calculator class to implement the
         associated operation when tapping a character in the calculator.
*/

import UIKit
import CalculatorKit

class CalcViewController: UIViewController {
    // MARK: - Properties
    
    var calculator = Calculator()
    @IBOutlet weak var display: UITextField!

    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Handle Tapped Character
    
    @IBAction func tap(_ sender: UIButton) {
        if let label = sender.titleLabel?.text {
            do {
                try calculator.input(label)
                display.text = calculator.displayValue
            } catch let error {
                print("\(error.localizedDescription)")
            }
        }
    }
}
