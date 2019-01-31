/*
  TypeSelectionViewController.swift
  Recipes_Swift

  Created by Seyed Samad Gholamzadeh on 2/2/18.
  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.

Abstract:
Table view controller to allow the user to select the recipe type.
The options are presented as items in the table view; the selected item has a check mark in the accessory view. The controller caches the index path of the selected item to avoid the need to perform repeated string comparisons after an update.
*/


import UIKit
import CoreData

class TypeSelectionViewController: UITableViewController {
	
	var recipe: Recipe!
	var recipeTypes: [Any]!
	
	let MyIdentifier = "MyIdentifier"
	
    override func viewDidLoad() {
        super.viewDidLoad()

		// Register this class for our cell to this table view under the specified identifier 'MyIdentifier'.
		self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: MyIdentifier)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(true)
		
		self.title = NSLocalizedString("Category", comment: "");
		
		// Right bar button item will dismiss this view controller.
		self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneAction(_:)))
		
		// Fetch the recipe types in alphabetical order by name from the recipe's context.
		let context = self.recipe.managedObjectContext
		
		let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
		fetchRequest.entity = NSEntityDescription.entity(forEntityName: "RecipeType", in: context!)
		let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
		let sortDescriptors = [sortDescriptor]
		fetchRequest.sortDescriptors = sortDescriptors
		do {
			let types = try context?.fetch(fetchRequest)
			self.recipeTypes = types
		}
		catch {
			print(error)
		}
	}


	@IBAction func doneAction(_ sender: Any) {
		self.dismiss(animated: true, completion: nil)
	}
	
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.recipeTypes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...
		let recipeType = self.recipeTypes[indexPath.row] as! RecipeType
		cell.textLabel?.text = (recipeType as AnyObject).value(forKey: "name") as? String
		if recipeType == self.recipe.type {
			cell.accessoryType = .checkmark
		}
        return cell
    }

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		// If there was a previous selection, unset the accessory view for its cell.
		
		if let currentType = self.recipe.type {
//			let index = self.recipeTypes.inde
			let index = (self.recipeTypes as NSArray).index(of: currentType)
			let selectionIndexPath = IndexPath(row: index, section: 0)
			let checkedCell = tableView.cellForRow(at: selectionIndexPath)
			checkedCell?.accessoryType = .none
		}
		
		// Set the checkmark accessory for the selected row.
		tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
		
		// Update the type of the recipe instance.
		self.recipe.type = self.recipeTypes![indexPath.row] as? RecipeType
		
		// Deselect the row.
		tableView.deselectRow(at: indexPath, animated: true)
	}
}
