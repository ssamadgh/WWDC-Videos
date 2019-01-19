//
//  NormalPagingViewController.swift
//  PhotoScrollerSwift
//
//  Created by Seyed Samad Gholamzadeh on 10/14/1396 AP.
//  Copyright © 1396 AP Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

class NormalPagingViewController: PagingBaseViewController {


    override func viewDidLoad() {
        super.viewDidLoad()
		print("view frame", self.view.frame)
		for i in 0..<3 {
			self.images.append(image(at: i))
		}
		
		self.pagingView.isParallaxScrollingEnabled = true
		self.pagingView.reloadData()

    }
	
	
	
	
	//MARK: - Image Wrangling
	
	lazy var imageData: [Any]? = {
		var data: [Any]? = nil
		
		DispatchQueue.global().sync {
			let path = Bundle.main.url(forResource: "ImageData", withExtension: "plist")
			do {
				let plistData = try Data(contentsOf: path!)
				data = try PropertyListSerialization.propertyList(from: plistData, options: PropertyListSerialization.ReadOptions.mutableContainers, format: nil) as? [Any]
				//				return data
			}
			catch {
				print("Unable to read image data: ", error)
			}
			
		}
		return data
	}()

	
	func imageName(at index: Int) -> String {
		if let info = imageData?[index] as? [String: Any] {
			return info["name"] as? String ?? ""
		}
		return ""
	}
	
	// we use "imageWithContentsOfFile:" instead of "imageNamed:" here to avoid caching
	func image(at index: Int) -> UIImage {
		let name = imageName(at: index)
		if let path = Bundle.main.path(forResource: name, ofType: "jpg") {
			return UIImage(contentsOfFile: path)!
		}
		return UIImage()
	}


}
