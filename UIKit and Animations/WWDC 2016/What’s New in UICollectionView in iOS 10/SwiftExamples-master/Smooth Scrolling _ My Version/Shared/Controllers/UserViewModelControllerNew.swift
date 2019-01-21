//
//  UserController.swift
//  SmoothScrolling
//
//  Created by Andrea Prearo on 10/29/16.
//  Copyright © 2016 Andrea Prearo. All rights reserved.
//

import Foundation
import ModelAssistant

typealias RetrieveUsersCompletionBlock = (_ success: Bool, _ error: NSError?) -> Void

class UserViewModelControllerNew {
	
	private let imageLoadQueue = OperationQueue()
	private var imageLoadOperations = [IndexPath: ImageLoadOperation2]()
	
	var assistant: ModelAssistant<UserViewModel>
	var delegateManager: ModelAssistantDelegateManager!
	
	init(controller: CollectionController) {
		self.assistant = ModelAssistant(sectionKey: nil)
		self.assistant.fetchBatchSize = 25
		delegateManager = ModelAssistantDelegateManager(controller: controller)
		self.assistant.delegate = delegateManager
	}
	
	private var nextPage: Int {
		return self.assistant.nextFetchIndex
	}
	
	private var lastPage: Int {
		return self.assistant.lastFetchIndex
	}
	
	var numberOfSections: Int {
		return self.assistant.numberOfSections
	}
	
	func numberOfRows(at section: Int) -> Int {
		let count = assistant.numberOfEntites(at: section)
		return count
	}
	
	private var retrieveUsersCompletionBlock: RetrieveUsersCompletionBlock?
	
	func retrieveUsers(_ completionBlock: @escaping RetrieveUsersCompletionBlock) {
		retrieveUsersCompletionBlock = completionBlock
		loadNextPageIfNeeded {
			
		}
	}
	
	
	func viewModel(at indexPath: IndexPath) -> UserViewModel? {
		return assistant[indexPath]
	}
	
	func downloadOperation(for viewModel: UserViewModel? = nil, at indexPath: IndexPath) {
		
		guard
//			imageLoadOperations[indexPath] == nil,
			let viewModel = viewModel ?? self.assistant[indexPath]
//			viewModel.needsToDownloadImage
			else {
				return
		}
		print("download indexPath \(indexPath.row) for name \(viewModel.username)")

		let imageLoadOperation = ImageLoadOperation2(viewModel: viewModel)
		imageLoadOperation.completionHandler = { [weak self] (image) in
			guard let `self` = self else {
				return
			}
			
			self.imageLoadOperations.removeValue(forKey: indexPath)
			self.assistant.update(viewModel, mutate: { (mutatedViewModel) in
				mutatedViewModel.image = image
			}, completion: nil)
			
		}
		
		imageLoadQueue.addOperation(imageLoadOperation)
		imageLoadOperations[indexPath] = imageLoadOperation
		
	}
	
	func cancelOperation(for indexPath: IndexPath) {
		guard let imageLoadOperation = imageLoadOperations[indexPath] else {
			return
		}
		imageLoadOperation.cancel()
		imageLoadOperations.removeValue(forKey: indexPath)
	}
	
}

private extension UserViewModelControllerNew {
	
	static func parse(_ jsonData: Data) -> [User?]? {
		do {
			return try JSONDecoder().decode([User].self, from: jsonData)
		} catch {
			return nil
		}
	}
	
	static func initViewModels(_ users: [User?], firstId: Int) -> [UserViewModel] {
		return users.compactMap { user in
			
			if let user = user {
				
				let index = users.firstIndex(where: { (checkingUser) -> Bool in
					return checkingUser?.username == user.username
				})
				return UserViewModel(user: user, id: firstId + index!)
			} else {
				return nil
			}
		}
	}
	
}

extension UserViewModelControllerNew {
	
	func loadNextPageIfNeeded(completion: @escaping () -> Void) {
		
		let pageSize = self.assistant.fetchBatchSize
		
		let id = nextPage * pageSize + 1
		let urlString = String(format: "https://aqueous-temple-22443.herokuapp.com/users?id=\(id)&count=\(pageSize)")
		guard let url = URL(string: urlString) else {
			retrieveUsersCompletionBlock?(false, nil)
			return
		}
		let session = URLSession.shared
		let task = session.dataTask(with: url) { [weak self] (data, response, error) in
			guard let strongSelf = self else { return }
			guard let jsonData = data, error == nil else {
				DispatchQueue.main.async {
					strongSelf.retrieveUsersCompletionBlock?(false, error as NSError?)
				}
				return
			}
			
			if let users = UserViewModelControllerNew.parse(jsonData) {
				let newUsersPage = UserViewModelControllerNew.initViewModels(users, firstId: id)
				strongSelf.assistant.insert(newUsersPage) {
					completion()
				}
				
				DispatchQueue.main.async {
					strongSelf.retrieveUsersCompletionBlock?(true, nil)
				}
				
			} else {
				
				DispatchQueue.main.async {
					strongSelf.retrieveUsersCompletionBlock?(false, NSError.createError(0, description: "JSON parsing error"))
				}
				
			}
		}
		task.resume()
	}
	
}
