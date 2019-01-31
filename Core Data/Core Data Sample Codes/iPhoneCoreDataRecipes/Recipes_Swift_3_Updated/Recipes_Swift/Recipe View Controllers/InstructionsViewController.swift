/*
  InstructionsViewController.swift
  Recipes_Swift

  Created by Seyed Samad Gholamzadeh on 2/2/18.
  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.

Abstract:
View controller to manage a text view to allow the user to edit instructions for a recipe.
*/


import UIKit

class InstructionsViewController: UIViewController {
	
	var recipe: Recipe!
	
	@IBOutlet weak var instructionsText: UITextView!
	@IBOutlet weak var nameLabel: UILabel!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.navigationItem.title = NSLocalizedString("Instructions", comment: "")
		self.navigationItem.rightBarButtonItem = self.editButtonItem
	}
	
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		// Update the views appropriately.
		self.nameLabel.text = self.recipe.name
		self.instructionsText.text = self.recipe.instructions
	}
	
	override func setEditing(_ editing: Bool, animated: Bool) {
		super.setEditing(editing, animated: animated)
		
		self.instructionsText.isEditable = editing
		self.navigationItem.setHidesBackButton(editing, animated: true)
		
		/*
		If editing is finished, update the recipe's instructions and save the managed object context.
		*/
		if !isEditing {
			self.recipe.instructions = self.instructionsText.text
			
			let context = self.recipe.managedObjectContext
			
			do {
				try context?.save()
			}
			catch {
				/*
				Replace this implementation with code to handle the error appropriately.
				
				abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
				*/

				print("Unresolved error :", error)
			}
		}
		
	}

	
	
}
