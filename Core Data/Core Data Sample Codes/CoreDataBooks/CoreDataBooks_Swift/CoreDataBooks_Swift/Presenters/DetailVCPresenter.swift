//
//  DetailVCPresenter.swift
//  CoreDataBooks_Swift
//
//  Created by Seyed Samad Gholamzadeh on 2/4/19.
//  Copyright © 2019 Seyed Samad Gholamzadeh. All rights reserved.
//

import Foundation
import AOperation

enum Details: Int {
	case title, author, copyright
	var name: String {
		switch self {
		case .title:
			return NSLocalizedString("title", comment: "display name for title");
			
		case .author:
			return NSLocalizedString("author", comment: "display name for author");
			
		case .copyright:
			return NSLocalizedString("copyright", comment: "display name for copyright");
		}

	}
}

class DetailVCPresenter: BasicPresenter {
	

	var operationQueue: AOperationQueue
	var book: Book

	var undoManager: UndoManager? {
		return self.book.managedObjectContext?.undoManager
	}
	
	lazy var dateFormatter: DateFormatter = {
		let dateFormatter = DateFormatter()
		dateFormatter.dateStyle = .medium
		dateFormatter.timeStyle = .none
		return dateFormatter
	}()

	var bookIsValidateForUpdate: Bool {
		do {
			try self.book.validateForUpdate()
			return true
		} catch {
			return false
		}
	}
	
	init(operationQueue: AOperationQueue, book: Book) {
		self.operationQueue = operationQueue
		self.book = book
	}
	
	func prepareForEditing(_ editing: Bool) {
		/*
		When editing starts, create and set an undo manager to track edits. Then register as an observer of undo manager change notifications, so that if an undo or redo operation is performed, the table view can be reloaded.
		When editing ends, de-register from the notification center and remove the undo manager, and save the changes.
		*/
		if editing {
			self.setUpUndoManager()
		}
		else {
			self.cleanUpUndoManager()
			// Save the changes.
			do {
				try self.book.managedObjectContext?.save()
			}
			catch {
				fatalError("save edit error \(error)")
			}
		}
	}
	
	// MARK: - Undo support
	func setUpUndoManager() {
		
		/*
		If the book's managed object context doesn't already have an undo manager, then create one and set it for the context and self.
		The view controller needs to keep a reference to the undo manager it creates so that it can determine whether to remove the undo manager when editing finishes.
		*/
		if self.book.managedObjectContext?.undoManager == nil {
			let anUndoManager = UndoManager()
			anUndoManager.levelsOfUndo = 3
			self.book.managedObjectContext?.undoManager = anUndoManager
		}
		
		// Register as an observer of the book's context's undo manager.
		let bookUndoManager = self.book.managedObjectContext?.undoManager
		let dnc = NotificationCenter.default
		dnc.addObserver(self, selector: #selector(DetailViewController.undoManagerDidUndo(_:)), name: NSNotification.Name.NSUndoManagerDidUndoChange, object: bookUndoManager)
		dnc.addObserver(self, selector: #selector(DetailViewController.undoManagerDidRedo(_:)), name: NSNotification.Name.NSUndoManagerDidRedoChange, object: bookUndoManager)
	}
	
	func cleanUpUndoManager() {
		// Remove self as an observer.
		let bookUndoManager = self.book.managedObjectContext?.undoManager
		let dnc = NotificationCenter.default
		dnc.removeObserver(self, name: NSNotification.Name.NSUndoManagerDidUndoChange, object: bookUndoManager)
		dnc.removeObserver(self, name: NSNotification.Name.NSUndoManagerDidRedoChange, object: bookUndoManager)
		self.book.managedObjectContext?.undoManager = nil
	}

	func bookInfo(info: (_ author: String?, _ title: String?, _ copyright: String?) -> Void) {
		let copyright = self.book.copyright != nil ? self.dateFormatter.string(from: self.book.copyright!) : nil
		info(self.book.author, self.book.title, copyright)
	}
	
	func prepare(_ vc: EditingViewController, for indexPath: IndexPath) {
		let editedField = Details(rawValue: indexPath.row)!
		let presenter = EditingVCPresenter(operationQueue: self.operationQueue, editedBook: self.book, editedField: editedField)
		vc.presenter = presenter
	}
		
}
