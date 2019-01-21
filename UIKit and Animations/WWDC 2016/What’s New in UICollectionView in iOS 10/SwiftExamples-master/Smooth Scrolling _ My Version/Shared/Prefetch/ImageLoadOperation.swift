//
//  ImageLoadOperation.swift
//  SmoothScrolling
//
//  Created by Andrea Prearo on 2/15/17.
//  Copyright © 2017 Andrea Prearo. All rights reserved.
//

import UIKit
import ModelAssistant

typealias ImageLoadOperationCompletionHandlerType = ((UIImage) -> ())?

//class ImageLoadOperation: Operation {
//    var url: String
//    var completionHandler: ImageLoadOperationCompletionHandlerType
//    var image: UIImage?
//
//    init(url: String) {
//        self.url = url
//    }
//
//    override func main() {
//        if isCancelled {
//            return
//        }
//
//        UIImage.downloadImageFromUrl(url) { [weak self] (image) in
//            guard let strongSelf = self,
//                !strongSelf.isCancelled,
//                let image = image else {
//                return
//            }
//            strongSelf.image = image
//            strongSelf.completionHandler?(image)
//        }
//    }
//}


class ImageLoadOperation2: Operation {
	
	var viewModel: UserViewModel
	var completionHandler: ImageLoadOperationCompletionHandlerType

	init(viewModel: UserViewModel) {
		self.viewModel = viewModel
	}
	
	override func main() {
		
		if isCancelled {
			return
		}
		
		self.downloadImageFromUrl(viewModel.avatarUrl) { [weak self] (image) in
			guard let strongSelf = self,
				!strongSelf.isCancelled,
				let image = image else {
					return
			}

			strongSelf.completionHandler?(image)
		}
	}
	
	func downloadImageFromUrl(_ url: String, completionHandler: @escaping (UIImage?) -> Void) {
		guard let url = URL(string: url) else {
			completionHandler(nil)
			return
		}
		let task: URLSessionDataTask = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) -> Void in
			guard let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
				let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
				let data = data, error == nil,
				let image = UIImage(data: data) else {
					completionHandler(nil)
					return
			}
			completionHandler(image)
		})
		task.resume()
	}

}
