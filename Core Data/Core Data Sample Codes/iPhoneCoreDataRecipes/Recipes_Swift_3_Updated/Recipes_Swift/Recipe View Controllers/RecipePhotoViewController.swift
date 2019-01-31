/*
  RecipePhotoViewController.swift
  Recipes_Swift

  Created by Seyed Samad Gholamzadeh on 2/2/18.
  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.

Abstract:
View controller to manage a view to display a recipe's photo.
The image view is created programmatically.
*/


import UIKit

class RecipePhotoViewController: UIViewController {

	var recipe: Recipe!
	var imageView: UIImageView!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.title = NSLocalizedString("Photo", comment: "")
		
		self.imageView = UIImageView(frame: UIScreen.main.bounds)
		self.imageView.contentMode = .scaleAspectFit
		self.imageView.backgroundColor = UIColor.black
		
		self.view = self.imageView
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		self.imageView.image = self.recipe.image?.image as! UIImage
	}

}
