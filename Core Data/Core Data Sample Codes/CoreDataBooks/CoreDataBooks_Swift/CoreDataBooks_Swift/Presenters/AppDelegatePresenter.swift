//
//  AppDelegatePresenter.swift
//  iOS_Exapmle
//
//  Created by Seyed Samad Gholamzadeh on 2/2/19.
//  Copyright © 2019 Seyed Samad Gholamzadeh. All rights reserved.
//

import Foundation
import AOperation


class AppDelegatePresenter: BasicPresenter {
	
	lazy var operationQueue = AOperationQueue()
	
	func initializeCoreDataStack(modelName: String, completion: @escaping (_ error: NSError?) -> Void ) {
		AOperatinLogger.printOperationsState = true
		CoreDataStack.modelName = modelName
		let op = InitializeCoreDataStackOperation()
		op.addCondition(DatabaseExistCondition())
		op.addObserver(BlockObserver { _ , errors in
			completion(errors.first)
		})
		self.operationQueue.addOperation(op)
	}
	
	func saveContext() {
		if CDStack.viewContext.hasChanges {
			do {
				try CDStack.viewContext.save()
			}
			catch {
				fatalError("error: \(error.localizedDescription)")
			}
		}
	}
	
	func prepare(_ rootVC: RootViewController) {
		rootVC.presenter = RootVCPresenter(operationQueue: self.operationQueue)
	}
	
}
