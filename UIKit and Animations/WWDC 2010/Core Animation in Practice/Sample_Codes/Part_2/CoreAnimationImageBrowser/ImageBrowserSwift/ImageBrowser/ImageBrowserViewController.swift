//
//  ViewController.swift
//  ImageBrowser
//
//  Created by Seyed Samad Gholamzadeh on 2/2/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

class ImageBrowserViewController: UIViewController {
	
	@IBOutlet weak var scrollView: ImageBrowserView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.scrollView.controller = self
		do {
			let imageDir = Bundle.main.url(forResource: "Images", withExtension: nil)
			let urls: [URL] = try FileManager.default.contentsOfDirectory(at: imageDir!, includingPropertiesForKeys: nil, options: FileManager.DirectoryEnumerationOptions.skipsHiddenFiles)
			self.scrollView.imageURLs = urls
		}
		catch {
			print(error)
		}
		
	}

}

