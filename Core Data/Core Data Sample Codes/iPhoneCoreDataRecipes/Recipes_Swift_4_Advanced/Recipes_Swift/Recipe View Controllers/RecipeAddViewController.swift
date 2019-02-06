/*
  RecipeAddViewController.swift
  Recipes_Swift

  Created by Seyed Samad Gholamzadeh on 1/26/18.
  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.

Abstract:
View controller to allow the user to add a new recipe and choose its picture using the image picker.
If the user taps Save, the recipe detail view controller is pushed so that the user can edit the new item.
*/


import UIKit

protocol RecipeAddDelegate {
	func recipeAddViewController(_ recipeAddViewController: RecipeAddViewController, didAdd recipe: Recipe?)
}

class RecipeAddViewController: UIViewController, UITextFieldDelegate {

	var recipe: Recipe!
	var delegate: RecipeAddDelegate!
	
	@IBOutlet weak var nameTextField: UITextField!
	
    override func viewDidLoad() {
        super.viewDidLoad()

		// Configure the navigation bar.
		self.navigationItem.title = NSLocalizedString("Add Recipe", comment: "")
		
		self.nameTextField.becomeFirstResponder()
    }
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		if textField == self.nameTextField {
			self.nameTextField.resignFirstResponder()
			self.save(self)
		}
		return true
	}

	@IBAction func save(_ sender: Any) {
		self.recipe.name = self.nameTextField.text
		
		do {
			try self.recipe.managedObjectContext?.save()
		}
		catch {
			/*
			Replace this implementation with code to handle the error appropriately.
			
			abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
			*/
			print("Unresolved error: ", error)
			abort()
		}
		
		self.delegate.recipeAddViewController(self, didAdd: self.recipe)
	}
	
	
	@IBAction func cancel(_ sender: Any) {
		self.recipe.managedObjectContext?.delete(self.recipe)
		
		do {
			try self.recipe.managedObjectContext?.save()
		}
		catch {
			/*
			Replace this implementation with code to handle the error appropriately.
			
			abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
			*/
			print("Unresolved error: ", error)
			abort()
		}
		self.delegate.recipeAddViewController(self, didAdd: nil)
	}
	
	
}
