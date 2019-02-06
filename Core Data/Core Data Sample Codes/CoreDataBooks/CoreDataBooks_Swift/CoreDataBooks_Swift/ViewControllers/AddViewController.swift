//
//  AddViewController.swift
//  CoreDataBooks_Swift
//
//  Created by Seyed Samad Gholamzadeh on 2/4/19.
//  Copyright © 2019 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit
import CoreData


class AddViewController: DetailViewController<AddVCPresenter> {
	

    override func viewDidLoad() {
        super.viewDidLoad()

		// Set up the undo manager and set editing state to YES.
		self.presenter.setUpUndoManager()
		self.isEditing = true
    }

	deinit {
		self.presenter.cleanUpUndoManager()
	}
		
	@IBAction func save(_ sender: Any) {
		// Set the action name for the undo operation.
		self.dismiss(animated: true, completion: nil)

		self.presenter.finishWithSave(true) {
		}
	}
	
	@IBAction func cancel(_ sender: Any) {
		
		// Don't pass current value to the edited object, just pop.
		self.dismiss(animated: true, completion: nil)

		self.presenter.finishWithSave(false) {
		}
	}

}
