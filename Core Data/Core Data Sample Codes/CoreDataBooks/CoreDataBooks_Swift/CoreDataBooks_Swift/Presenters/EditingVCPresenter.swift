//
//  EditingVCPresenter.swift
//  CoreDataBooks_Swift
//
//  Created by Seyed Samad Gholamzadeh on 2/4/19.
//  Copyright © 2019 Seyed Samad Gholamzadeh. All rights reserved.
//

import Foundation
import AOperation
import CoreData

class EditingVCPresenter: BasicPresenter {
	
	var operationQueue: AOperationQueue
	var editedBook: Book
	var editedField: Details
		
	var editingDate: Date {
		return self.editedBook.copyright ?? Date()
	}
	
	var editingText: String? {
		return self.editedField == .title ? self.editedBook.title : editedBook.author
	}
	
	var title: String! {
		return self.editedField.name
	}

	var isEditingDate: Bool {
		return self.editedField == .copyright
	}
	
	init(operationQueue: AOperationQueue, editedBook: Book, editedField: Details) {
		self.operationQueue = operationQueue
		self.editedBook = editedBook
		self.editedField = editedField
	}
	
	private func setActionNameForUndoOperation() {
		// Set the action name for the undo operation.
		let undoManager = self.editedBook.managedObjectContext?.undoManager
		undoManager?.setActionName("\(self.editedField.name)")
	}
	
	func save(_ date: Date) {
		self.setActionNameForUndoOperation()
		self.editedBook.copyright = date
	}
	
	func save( _ text: String?) {
		self.setActionNameForUndoOperation()
		if self.editedField == .title {
			self.editedBook.title = text
		}
		else {
			self.editedBook.author = text
		}
	}

}
