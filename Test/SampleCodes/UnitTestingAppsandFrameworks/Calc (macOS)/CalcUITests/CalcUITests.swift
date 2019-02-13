/*
 Copyright (C) 2018 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 Performs UI testing for the Calc app.
*/

import XCTest

class CalcUITests: XCTestCase {
    let app = XCUIApplication().windows["Calc"]

    // MARK: - Setup and Teardown
    
    override func setUp() {
        super.setUp()
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    // MARK: - Addition
    
    /**
        Performs a chained addition test. The test has two parts:
        1. Enter in the calculator and check: 6 + 2 = 8.
        2. Check: display value + 2 = 10.
    */
    func testAddition() {
        app.buttons["6"].click()
        app.buttons["+"].click()
        app.buttons["2"].click()
        app.buttons["="].click()
        
        // Check whether the display textfield shows 8.
        if let textFieldValue = app.textFields["display"].value as? String {
            XCTAssertTrue(textFieldValue == "8", "Incorrect value.")
        }
        
        app.buttons["+"].click()
        app.buttons["2"].click()
        app.buttons["="].click()
        
        // Check whether the display textfield shows 10.
        if let textFieldValue = app.textFields["display"].value as? String {
            XCTAssertTrue(textFieldValue == "10", "Incorrect value.")
        }
    }

    // MARK: - Subtraction
    
    /// Performs a substraction test. Enter in the calculator and check: 6 - 2 = 4.
    func testSubtraction() {
        app.buttons["6"].click()
        app.buttons["-"].click()
        app.buttons["2"].click()
        app.buttons["="].click()
        
        // Check that whether the display textfield shows 4.
        if let textFieldValue = app.textFields["display"].value as? String {
            XCTAssertTrue(textFieldValue == "4", "Incorrect value.")
        }
    }
    
    // MARK: - Division
    
    /// Performs a division test. Enter in the calculator and check: 25 / 4 = 6.25.
    func testDivision() {
        app.buttons["2"].click()
        app.buttons["5"].click()
        app.buttons["/"].click()
        app.buttons["4"].click()
        app.buttons["="].click()
        
        // Check whether the display textfield shows 6.25.
        if let textFieldValue = app.textFields["display"].value as? String {
            XCTAssertTrue(textFieldValue == "6.25", "Incorrect value.")
        }
    }

    // MARK: - Multiplication
    
    /// Performs a multiplication test. Enter in the calculator and check: 19 x 8 = 152.
    func testMultiplication() {
        app.buttons["1"].click()
        app.buttons["9"].click()
        app.buttons["*"].click()
        app.buttons["8"].click()
        app.buttons["="].click()
        
         // Check whether the display textfield shows 152.
        if let textFieldValue = app.textFields["display"].value as? String {
            XCTAssertTrue(textFieldValue == "152", "Incorrect value.")
        }
    }

    // MARK: - Delete
    
    /**
        Tests the functionality of the D (Delete) key.
        1. Enter the number 1987 into the calculator.
        2. Delete each digit, and test the display to ensure
        the correct display contains the expected value after each D tap.
    */
    func testDelete() {
        app.buttons["1"].click()
        app.buttons["9"].click()
        app.buttons["8"].click()
        app.buttons["7"].click()
        app.buttons["="].click()
        
        if let textFieldValue = app.textFields["display"].value as? String {
            XCTAssertTrue(textFieldValue == "1987", "Incorrect value.")
        }
        
        app.buttons["D"].click()
        if let textFieldValue = app.textFields["display"].value as? String {
            XCTAssertTrue(textFieldValue == "198", "Incorrect value.")
        }
        
        app.buttons["D"].click()
        if let textFieldValue = app.textFields["display"].value as? String {
            XCTAssertTrue(textFieldValue == "19", "Incorrect value.")
        }
        
        app.buttons["D"].click()
        
        if let textFieldValue = app.textFields["display"].value as? String {
            XCTAssertTrue(textFieldValue == "1", "Incorrect value.")
        }
        
        app.buttons["D"].click()
        if let textFieldValue = app.textFields["display"].value as? String {
            XCTAssertTrue(textFieldValue == "0", "Incorrect value.")
        }
    }
    
    // MARK: - Clear
    
    /**
        Tests the functionality of the C (Clear) key.
        1. Clear the display.
            - Enter the calculation 25 / 4.
            - Tap C.
            - Ensure the display contains the value 0.
        2. Perform corrected computation.
            - Tap 5, =.
            - Ensure the display contains the value 5.
        3. Ensure tapping C twice clears all.
            - Enter the calculation 19 x 8.
            - Tap C (clears the display).
            - Tap C (clears the operand).
            - Tap +, 2, =.
            - Ensure the display contains the value 2.
    */
    func testClear() {
        app.buttons["2"].click()
        app.buttons["5"].click()
        app.buttons["/"].click()
        app.buttons["4"].click()
        app.buttons["="].click()
        app.buttons["C"].click()
        if let textFieldValue = app.textFields["display"].value as? String {
            XCTAssertTrue(textFieldValue == "0", "Incorrect value.")
        }
        
        app.buttons["5"].click()
        app.buttons["="].click()
        if let textFieldValue = app.textFields["display"].value as? String {
            XCTAssertTrue(textFieldValue == "5", "Incorrect value.")
        }
        
        app.buttons["1"].click()
        app.buttons["9"].click()
        app.buttons["*"].click()
        app.buttons["8"].click()
        app.buttons["C"].click()
        app.buttons["C"].click()
        app.buttons["+"].click()
        app.buttons["2"].click()
        app.buttons["="].click()
        if let textFieldValue = app.textFields["display"].value as? String {
            XCTAssertTrue(textFieldValue == "2", "Incorrect value.")
        }
    }
}
