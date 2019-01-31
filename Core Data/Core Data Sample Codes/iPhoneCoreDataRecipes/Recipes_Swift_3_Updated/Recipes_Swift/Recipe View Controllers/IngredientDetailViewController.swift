/*
  IngredientDetailViewController.swift
  Recipes_Swift

  Created by Seyed Samad Gholamzadeh on 2/2/18.
  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.

Abstract:
Table view controller to manage editing details of a recipe ingredient -- its name and amount.
*/


import UIKit
import CoreData

class IngredientDetailViewController: UITableViewController, UITextFieldDelegate {
	
	var recipe: Recipe!
	var ingredient: Ingredient! {
		didSet {
			self.ingredientStr = self.ingredient.name
			self.amountStr = self.ingredient.amount
		}
	}
	
	// Table's data source.
	var ingredientStr: String!
	var amountStr: String!

	// View tags for each UITextField.
	let kIngredientFieldTag = 1
	let kAmountFieldTag = 2

	let IngredientsCellIdentifier = "IngredientsCell"

	
    override func viewDidLoad() {
        super.viewDidLoad()

		
		self.title = NSLocalizedString("Ingredient", comment: "")
		
		self.tableView.allowsSelection = false
		self.tableView.allowsSelectionDuringEditing = false
    }
	
	
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 2
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: IngredientsCellIdentifier, for: indexPath) as! EditingTableViewCell
		
		if indexPath.row == 0 {
			// Cell ingredient name.
			cell.label.text = NSLocalizedString("Ingredient", comment: "");
			cell.textField.text = self.ingredientStr;
			cell.textField.placeholder = NSLocalizedString("Name", comment: "");
			cell.textField.tag = kIngredientFieldTag;
		}
		else if (indexPath.row == 1) {
			// Cell ingredient amount.
			cell.label.text = NSLocalizedString("Amount", comment: "");
			cell.textField.text = self.amountStr;
			cell.textField.placeholder = NSLocalizedString("Amount", comment: "");
			cell.textField.tag = kAmountFieldTag;
		}

        return cell
    }
	
	@IBAction func save(_ sender: Any) {
		let context = self.recipe.managedObjectContext!
		
		// If there isn't an ingredient object, create and configure one.
		if self.ingredient == nil {
			self.ingredient = NSEntityDescription.insertNewObject(forEntityName: "Ingredient", into: context) as! Ingredient
			self.recipe.addToIngredients(self.ingredient)
			self.ingredient.displayOrder = Int16(self.recipe.ingredients!.count)
		}
		
		// Update the ingredient from the values in the text fields.
		var cell: EditingTableViewCell!
		
		cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! EditingTableViewCell
		self.ingredient.name = cell.textField.text
		
		
		cell = self.tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as! EditingTableViewCell
		self.ingredient.amount = cell.textField.text;
		
		// Save the managed object context.
		do {
			try context.save()
		}
		catch {
			/*
			Replace this implementation with code to handle the error appropriately.
			
			abort() causes the application to generate a crash log and terminate.
			You should not use this function in a shipping application, although it may be
			useful during development. If it is not possible to recover from the error, display
			an alert panel that instructs the user to quit the application by pressing the Home button.
			*/
			print("Unresolved error : ", error)
		}
		
		self.parent?.dismiss(animated: true, completion: nil)
	}
	
	@IBAction func cancel(_ sender: Any) {
		self.parent?.dismiss(animated: true, completion: nil)
	}
	
	func textFieldDidEndEditing(_ textField: UITextField) {
		// Editing has ended in one of our text fields, assign it's text to the right
		// ivar based on the view tag.
		//
		switch textField.tag
		{
		case kIngredientFieldTag:
			self.ingredientStr = textField.text
			break;
			
		case kAmountFieldTag:
			self.amountStr = textField.text
			break;
		default:
			break
		}

	}
}
