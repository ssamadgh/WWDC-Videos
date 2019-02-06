/*
Copyright (C) 2017 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
Table view controller to manage an editable table view that displays a list of recipes.
Recipes are displayed in a custom table view cell.
*/

import UIKit
import CoreData

// Segue ID when "+" button is tapped.
private let kShowRecipeSegueID = "showRecipe";

// Segue ID when "Add Ingredient" cell is tapped.
private let kAddRecipeSegueID = "addRecipe";


class RecipeListTableViewController: UITableViewController, RecipeAddDelegate, NSFetchedResultsControllerDelegate {
	
	var managedObjectContext: NSManagedObjectContext!
	
	var fetchedResultsController: NSFetchedResultsController<Recipe>!
	
    override func viewDidLoad() {
        super.viewDidLoad()

		// Add the table's edit button to the left side of the nav bar.
		self.navigationItem.leftBarButtonItem = self.editButtonItem
		
		// Set the table view's row height.
		self.tableView.rowHeight = 44.0
		
		// Set up the fetched results controller if needed.
		// Create the fetch request for the entity.
		let fetchRequest = Recipe.fetchRequest() as NSFetchRequest
		
		// Edit the sort key as appropriate.
		let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
		let sortDescriptors = [sortDescriptor]
		
		fetchRequest.sortDescriptors = sortDescriptors
		
		// Edit the section name key path and cache name if appropriate.
		// nil for section name key path means "no sections".
		self.fetchedResultsController = NSFetchedResultsController<Recipe>(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
		self.fetchedResultsController.delegate = self
		
		try! self.fetchedResultsController.performFetch()
    }

	
	//MARK: - Recipe support
	func recipeAddViewController(_ recipeAddViewController: RecipeAddViewController, didAdd recipe: Recipe?) {
		if recipe != nil  {
			// Show the recipe in the RecipeDetailViewController.
			self.performSegue(withIdentifier: kShowRecipeSegueID, sender: recipe!)
		}
		
		// Dismiss the RecipeAddViewController.
		self.dismiss(animated: true, completion: nil)
	}
	
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
		if let count = self.fetchedResultsController.sections?.count, count != 0 {
			return count
		}
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
		var numberOfRows = 0
		
		if let count = self.fetchedResultsController.sections?.count, count > 0 {
			if let sectionInfo = self.fetchedResultsController.sections?[section] {
				numberOfRows = sectionInfo.numberOfObjects
			}
		}
		
		return numberOfRows;
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		// Dequeue a RecipeTableViewCell, then set its recipe to the recipe for the current row.
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyIdentifier", for: indexPath) as! RecipeTableViewCell

        // Configure the cell...
		self.configure(cell, at: indexPath)

        return cell
    }
	
	func configure( _ cell: RecipeTableViewCell, at indexPath: IndexPath) {
		let recipe = self.fetchedResultsController.object(at: indexPath)
		cell.recipe = recipe
	}

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
			// Delete the managed object for the given index path.
			let context = self.fetchedResultsController.managedObjectContext
			context.delete(self.fetchedResultsController.object(at: indexPath))
			try! context.save()
			
        }
	}

	/**
	Delegate methods of NSFetchedResultsController to respond to additions, removals and so on.
	*/
	func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		
		// The fetch controller is about to start sending change notifications, so prepare the table view for updates.
		self.tableView.beginUpdates()
	}
	
	func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
		
		let tableView = self.tableView!
		
		switch type {
		case .insert:
			tableView.insertRows(at: [newIndexPath!], with: .fade)
		case .delete:
			tableView.deleteRows(at: [indexPath!], with: .fade)
		case .update:
			self.configure(tableView.cellForRow(at: indexPath!) as! RecipeTableViewCell, at: indexPath!)

		default:
			break
		}
	}
	
	
	func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
		switch type {
		case .insert:
			self.tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
		case .delete:
			self.tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
		default:
			break
		}
	}
	
	
	
	func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		self.tableView.endUpdates()
	}
	
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		
		if segue.identifier == kShowRecipeSegueID {
			// Show a Recipe
			let detailViewController = segue.destination as! RecipeDetailTableViewController
			let recipe: Recipe
			if sender is Recipe {
				// The sender is the actual recipe send from "didAddRecipe" delegate (user created a new recipe).
				recipe = sender as! Recipe
				
			}
			else {
				// The sender is ourselves (user tapped an existing recipe).
				let indexPath = self.tableView.indexPathForSelectedRow
				recipe = self.fetchedResultsController.object(at: indexPath!)
			}
			detailViewController.recipe = recipe

		}
		else if segue.identifier == kAddRecipeSegueID {
			// Add a Recipe
			let newRecipe = Recipe(context: self.managedObjectContext)
			let navController = segue.destination as! UINavigationController
			let addController = navController.topViewController as! RecipeAddViewController
			addController.delegate = self // Do didAddRecipe delegate method is called when cancel or save are tapped.
			addController.recipe = newRecipe
		}

	}

}
