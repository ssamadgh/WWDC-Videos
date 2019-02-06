//
//  CoreDataController.swift
//  iVisit
//
//  Created by Seyed Samad Gholamzadeh on 11/27/1396 AP.
//  Copyright © 1396 AP Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit
import CoreData
import AOperation


var CDStack: CoreDataStack! {
	get {
		return CoreDataStack.shared
	}
	
	set {
		CoreDataStack.shared = newValue
	}
}

class CoreDataStack {
	
	static var shared: CoreDataStack!
	
	static var modelName: String!
	static let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last?.appendingPathComponent("CoreDataBooks_Swift.sqlite")

	var container: NSPersistentContainer!
	
	var viewContext: NSManagedObjectContext {
		return container.viewContext
	}
	
}


class InitializeCoreDataStackOperation: AOperation {
	
	override func execute() {
		
		guard CDStack == nil else {
			finishWithError(nil)
			return
		}
		
		let stack = CoreDataStack()
		stack.container = NSPersistentContainer(name: CoreDataStack.modelName)
		let container = stack.container!
		let storeDescription = NSPersistentStoreDescription(url: CoreDataStack.storeURL!)
//		storeDescription.setOption(FileProtectionType.complete as NSObject, forKey: NSPersistentStoreFileProtectionKey)
		container.persistentStoreDescriptions = [storeDescription]
		container.loadPersistentStores { (description, error) in
			if let error = error {
				fatalError("Failed to load Core Data stack: \(error)")
			}
		}

		CDStack = stack
		self.finishWithError(nil)
	}
	
}

struct CoreDataStackAvailablity: OperationCondition {
	
	static var name: String = "CoreDataStackAvailablity"
	
	static var isMutuallyExclusive: Bool = true
	
	func dependencyForOperation(_ operation: AOperation) -> Operation? {
		return InitializeCoreDataStackOperation()
	}
	
	func evaluateForOperation(_ operation: AOperation, completion: @escaping (OperationConditionResult) -> Void) {
		let result: OperationConditionResult
		
		if CDStack != nil {
			result = .satisfied
		}
		else {
			let error = NSError(code: .conditionFailed, userInfo: [
				AOperationError.reason: type(of: self).name,
				])
			result = .failed(error)
		}
		
		completion(result)
	}
	
}

struct DatabaseExistCondition: OperationCondition {
	
	static var name: String = "DatabaseExistCondition"
	
	static var isMutuallyExclusive: Bool = false
	
	func dependencyForOperation(_ operation: AOperation) -> Operation? {
		return CheckDatabaseExistOperation()
	}
	
	func evaluateForOperation(_ operation: AOperation, completion: @escaping (OperationConditionResult) -> Void) {
		let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last?.appendingPathComponent("CoreDataBooks_Swift.sqlite")
		if !FileManager.default.fileExists(atPath: storeURL!.path) {
			completion(.satisfied)
		}
		else {
			let error = NSError(code: .conditionFailed, userInfo: [AOperationError.reason: "store does not exist in document"])
			completion(.failed(error))
		}
	}
	
	
}


class CheckDatabaseExistOperation: AOperation {
	//CoreDataBooks_Swift.sqlite
	override func execute() {
		let defaultStoreURL = Bundle.main.url(forResource: "CoreDataBooks_Swift", withExtension: "sqlite")
		let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last?.appendingPathComponent("CoreDataBooks_Swift.sqlite")
		
		assert(defaultStoreURL != nil, "defaultStoreURL shouldn't be nil")
		print("store address is: \(storeURL!.path)")
		
		do {
			if !FileManager.default.fileExists(atPath: storeURL!.path) {
				
				try FileManager.default.copyItem(at: defaultStoreURL!, to: storeURL!)
			}
			finishWithError(nil)
		}
		catch {
			let error = NSError(code: .executionFailed, userInfo: [AOperationError.reason: "Unable to copy store to document folder", description : error.localizedDescription])
			finishWithError(error)
		}
		
	}
	
}

