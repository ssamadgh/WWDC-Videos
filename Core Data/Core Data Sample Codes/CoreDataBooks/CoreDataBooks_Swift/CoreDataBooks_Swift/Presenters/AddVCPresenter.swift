//
//  AddVCPresenter.swift
//  CoreDataBooks_Swift
//
//  Created by Seyed Samad Gholamzadeh on 2/4/19.
//  Copyright © 2019 Seyed Samad Gholamzadeh. All rights reserved.
//

import Foundation
import CoreData

protocol AddVCPresenterDelegate: class {
	func addVCPresenter(_ presenter: AddVCPresenter, didFinishWithSave save: Bool)
}

class AddVCPresenter: DetailVCPresenter {
	
	var managedObjectContext: NSManagedObjectContext!
	
	var delegate: AddVCPresenterDelegate?
	
	func finishWithSave(_ save: Bool, completion: () -> Void) {
		self.delegate?.addVCPresenter(self, didFinishWithSave: save)
		completion()
	}

}
