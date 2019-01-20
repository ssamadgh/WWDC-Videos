//
//  APLDetailViewController.swift
//  CollectionViewTransition_Swift
//
//  Created by Seyed Samad Gholamzadeh on 6/30/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

class APLDetailViewController: UIViewController {

	var image: UIImage!
	@IBOutlet weak var imageView: UIImageView!


	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		// setup our image view if an image was set to this view controller
		self.imageView.image = self.image
	}
	
}
