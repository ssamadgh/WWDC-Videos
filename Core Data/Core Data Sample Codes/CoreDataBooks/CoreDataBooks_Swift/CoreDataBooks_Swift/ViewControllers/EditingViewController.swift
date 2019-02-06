//
//  EditingViewController.swift
//  CoreDataBooks_Swift
//
//  Created by Seyed Samad Gholamzadeh on 2/4/19.
//  Copyright © 2019 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit
import CoreData

class EditingViewController: UIViewController {

	var presenter: EditingVCPresenter!
	
	@IBOutlet weak var textField: UITextField!
	@IBOutlet weak var datePicker: UIDatePicker!
	

	
    override func viewDidLoad() {
        super.viewDidLoad()

		// Set the title to the user-visible name of the field.
		self.title = self.presenter.title
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		// Configure the user interface according to state.
		if self.presenter.isEditingDate {
			self.textField.isHidden = true
			self.datePicker.isHidden = false
			self.datePicker.date = self.presenter.editingDate
		}
		else {
			self.textField.isHidden = false
			self.datePicker.isHidden = true
			self.textField.text = self.presenter.editingText
			self.textField.placeholder = self.title
			self.textField.becomeFirstResponder()
		}
	}
	
	// MARK: - Save and cancel operations
	
	@IBAction func save(_ sender: Any) {
		if self.presenter.isEditingDate {
			self.presenter.save(self.datePicker.date)
		}
		else {
			self.presenter.save(self.textField.text)
		}
		self.navigationController?.popViewController(animated: true)
	}
	
	@IBAction func cancel(_ sender: Any) {
		// Don't pass current value to the edited object, just pop.
		self.navigationController?.popViewController(animated: true)
	}


}
