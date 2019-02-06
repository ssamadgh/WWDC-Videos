/*
  RecipeDetailTableViewController.swift
  Recipes_Swift

  Created by Seyed Samad Gholamzadeh on 1/27/18.
  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.

Abstract:
Table view controller to manage an editable table view that displays information about a recipe.
The table view uses different cell types for different row types.
*/


import UIKit
import CoreData

class RecipeDetailTableViewController: UITableViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate {
	
	var recipe: Recipe!
	
	var ingredients : [Ingredient]!
	@IBOutlet weak var photoButton: UIButton!
	@IBOutlet weak var nameTextField: UITextField!
	@IBOutlet weak var overviewTextField: UITextField!
	@IBOutlet weak var prepTimeTextField: UITextField!
	var singleEdit: Bool = false // Indicates user is swipe-deleting a particular ingredient.
	
	// Table's section indexes.
	enum Section: Int {
		case type, ingredients, instructions
		static let array = [type, ingredients, instructions]
	}
	
	// Segue ID when "Add Ingredient" cell is tapped.
	let kAddIngredientSegueID = "addIngredient"
	
	// Segue ID when "Instructions" cell is tapped.
	let kShowInstructionsSegueID = "showInstructions"
	
	// Segue ID when the recipe (category) cell is tapped.
	let kShowRecipeTypeSegueID = "showRecipeType"
	
	//MARK: - View controller
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.navigationItem.rightBarButtonItem = self.editButtonItem
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		self.photoButton.setImage(self.recipe.thumbnailImage, for: .normal)
		self.navigationItem.title = self.recipe.name
		self.nameTextField.text = self.recipe.name
		self.overviewTextField.text = self.recipe.overview
		self.prepTimeTextField.text = self.recipe.prepTime
		self.updatePhotoButton()
		
		/*
		Create a mutable array that contains the recipe's ingredients ordered by displayOrder.
		The table view uses this array to display the ingredients.
		Core Data relationships are represented by sets, so have no inherent order.
		Order is "imposed" using the displayOrder attribute, but it would be inefficient to create
		and sort a new array each time the ingredients section had to be laid out or updated.
		*/
		//		let sortDescriptor = NSSortDescriptor(key: "displayOrder", ascending: true)
		//		let sortDescriptors = [sortDescriptor]
		let sortedIngredients = (self.recipe.ingredients?.allObjects as! [Ingredient]).sorted { $0.displayOrder < $1.displayOrder }
		
		//		try! sortedIngredients.sorted { $0.displayOrder < $1.displayOrder }
		
		self.ingredients = sortedIngredients
		
		// update recipe type and ingredients on return
		self.tableView.reloadData()
	}
	
	//MARK: - Editing
	
	override func setEditing(_ editing: Bool, animated: Bool) {
		super.setEditing(editing, animated: animated)
		
		if !self.singleEdit {
			self.updatePhotoButton()
			self.nameTextField.isEnabled = editing
			self.overviewTextField.isEnabled = editing
			self.prepTimeTextField.isEnabled = editing
			self.navigationItem.setHidesBackButton(editing, animated: true)
			
			self.tableView.beginUpdates()
			
			let ingredientscount = self.recipe.ingredients!.count
			
			let ingredientsInsertIndexPath = IndexPath(row: ingredientscount, section: Section.ingredients.rawValue)
			
			if editing {
				self.tableView.insertRows(at: [ingredientsInsertIndexPath], with: .top)
				self.overviewTextField.placeholder = NSLocalizedString("Overview", comment: "")
			}
			else {
				self.tableView.deleteRows(at: [ingredientsInsertIndexPath], with: .top)
				self.overviewTextField.placeholder = "";
			}
			
			self.tableView.endUpdates()
		}
		
		
		/*
		If editing is finished, save the managed object context.
		*/
		if !editing {
			let context = self.recipe.managedObjectContext
			
			do {
				try context?.save()
			}
			catch {
				/*
				Replace this implementation with code to handle the error appropriately.
				
				abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
				*/
				
				print("Unresolved error", error)
			}
		}
	}
	
	func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
		
		if (textField == self.nameTextField) {
			self.recipe.name = self.nameTextField.text
			self.navigationItem.title = self.recipe.name
		}
		else if (textField == self.overviewTextField) {
			self.recipe.overview = self.overviewTextField.text
		}
		else if (textField == self.prepTimeTextField) {
			self.recipe.prepTime = self.prepTimeTextField.text
		}
		return true
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return true
	}
	
	// MARK: - Table view data source
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		// #warning Incomplete implementation, return the number of sections
		return Section.array.count
	}
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		var title: String? = nil
		
		// return a title or nil as appropriate for the section
		
		switch section {
		case Section.type.rawValue:
			title = "Category"
		case Section.ingredients.rawValue:
			title = "Ingredients"
		default: break
		}
		
		return title;
		
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		var rows: Int = 0
		
		/*
		The number of rows depends on the section.
		In the case of ingredients, if editing, add a row in editing mode to present an "Add Ingredient" cell.
		*/
		switch section {
		case Section.type.rawValue, Section.instructions.rawValue:
			// These sections have only one row.
			rows = 1
			
		case Section.ingredients.rawValue:
			rows = self.recipe.ingredients!.count
			if (self.isEditing) {
				rows += 1
			}
			
		default: break
		}
		
		return rows
	}
	
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		var cell: UITableViewCell? = nil
		
		// For the Ingredients section, if necessary create a new cell and configure it with
		// an additional label for the amount.  Give the cell a different identifier from that
		// used for cells in other sections so that it can be dequeued separately.
		
		if indexPath.section == Section.ingredients.rawValue {
			let ingredientCount = self.recipe.ingredients!.count
			let row = indexPath.row
			
			if indexPath.row < ingredientCount {
				// If the row is within the range of the number of ingredients for the current recipe,
				// then configure the cell to show the ingredient name and amount.
				
				cell = tableView.dequeueReusableCell(withIdentifier: "IngredientsCell", for: indexPath)
				let ingredient = self.ingredients[row]
				cell?.textLabel?.text = ingredient.name
				cell?.detailTextLabel?.text = ingredient.amount
				
				
			}
			else {
				// If the row is outside the range, it's the row that was added to allow insertion.
				// (see tableView:numberOfRowsInSection:) so give it an appropriate label.
				
				cell = tableView.dequeueReusableCell(withIdentifier: "AddIngredientCellIdentifier", for: indexPath)
			}
		}
		else {
			switch (indexPath.section) {
			case Section.type.rawValue:  // recipe type cell
				cell = tableView.dequeueReusableCell(withIdentifier: "RecipeType", for: indexPath)
				cell?.textLabel?.text = self.recipe.type?.name
				
			default:
				cell = tableView.dequeueReusableCell(withIdentifier: "Instructions", for: indexPath)
				
			}
			
		}
		
		return cell!
	}
	
	//MARK: - UITableViewDelegate
	
	override func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
		// User has started a swipe to delete operation.
		self.singleEdit = true
	}
	
	override func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
		// Swipe to delete operation has ended.
		self.singleEdit = false
	}
	
	func ingredient(byName ingredientName: String) -> Ingredient? {
		var ingredient: Ingredient? = nil
		let ingredients = self.recipe.ingredients?.allObjects as! [Ingredient]
		
		for entity in ingredients {
			if entity.name == ingredientName {
				ingredient = entity
				break  // We found the right ingredient by title.
			}
		}
		
		return ingredient
	}
	
	
	override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
		if indexPath.section == Section.type.rawValue && indexPath.row == 0 {
			// Edit the recipe "type"- pass the recipe.
			//
			let typeSelectionViewController = TypeSelectionViewController(style: .plain)
			typeSelectionViewController.recipe = recipe
			
			// Present modally the recipe type view controller.
			let navController = UINavigationController(rootViewController: typeSelectionViewController)
			navController.modalPresentationStyle = .fullScreen
			self.navigationController?.present(navController, animated: true, completion: nil)
		}
		else if indexPath.section == Section.ingredients.rawValue {
			// Edit the recipe "ingredient" - pass the ingredient.
			//
			let ingredientDetailViewController = self.storyboard?.instantiateViewController(withIdentifier: "IngredientDetailViewController") as! IngredientDetailViewController
			ingredientDetailViewController.recipe = self.recipe
			
			// Find the selected ingredient table cell (based on indexPath),
			// use it's ingredient title to find the right ingredient object in this recipe.
			// note: you can't use indexPath.row to lookup the recipe's ingredient object because NSSet is not ordered.
			//
			let ingredientCell = tableView.cellForRow(at: indexPath)
			ingredientDetailViewController.ingredient = self.ingredient(byName: ingredientCell!.textLabel!.text!)
			
			// Present modally the ingredient detail view controller.
			let navController = UINavigationController(rootViewController: ingredientDetailViewController)
			navController.modalPresentationStyle = .fullScreen
			self.navigationController?.present(navController, animated: true, completion: nil)
		}
	}
	
	override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
		var rowToSelect: IndexPath? = indexPath
		let section = indexPath.section
		let isEditing = self.isEditing

		// If editing, don't allow instructions to be selected
		// Not editing: Only allow instructions to be selected
		//

		if isEditing && section == Section.instructions.rawValue || !isEditing && section != Section.instructions.rawValue {
			tableView.deselectRow(at: indexPath, animated: true)
			rowToSelect = nil
		}

		return rowToSelect

	}
		
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		
		if segue.identifier == kAddIngredientSegueID {
			// Add an ingredient.
			//
			var recipe: Recipe? = nil
			if sender is Recipe {
				// The sender is the actual recipe send from "didAddRecipe" delegate (user created a new recipe)
				// pass the recipe.
				recipe = sender as? Recipe
				
				let navController = segue.destination as! UINavigationController
				let ingredientDetailViewController = navController.topViewController as! IngredientDetailViewController
				ingredientDetailViewController.recipe = recipe
			}
		}
		else if segue.identifier == kShowInstructionsSegueID {
			// Show and/or edit the instructions - pass the recipe.
			//
			let instructionsViewController = segue.destination as! InstructionsViewController
			instructionsViewController.recipe = self.recipe
			instructionsViewController.recipe = self.recipe;
		}
	}
	
	override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
		var style = UITableViewCellEditingStyle.none
		
		// Only allow editing in the ingredients section.
		// In the ingredients section, the last row (row number equal to the count of ingredients)
		// is added automatically (see tableView:cellForRowAtIndexPath:) to provide an insertion cell,
		// so configure that cell for insertion; the other cells are configured for deletion.
		//
		if indexPath.section == Section.ingredients.rawValue {
			// If this is the last item, it's the insertion row.
			if indexPath.row == self.recipe.ingredients?.count {
				style = .insert
			}
			else {
				style = .delete
			}
		}
		
		return style

	}
	

	// Override to support editing the table view.
	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
		
		// Only allow deletion, and only in the ingredients section
		if editingStyle == .delete && indexPath.section == Section.ingredients.rawValue {
			// Remove the corresponding ingredient object from the recipe's ingredient list and delete the appropriate table view cell.
			let ingredient = self.ingredients[indexPath.row]
			self.ingredients.remove(at: indexPath.row)
			self.recipe.removeFromIngredients(ingredient)
			
			let context = ingredient.managedObjectContext
			context?.delete(ingredient)
			
			self.tableView.deleteRows(at: [indexPath], with: .automatic)
		} else if editingStyle == .insert {
			// User tapped the "+" button to add a new ingredient.
			self.performSegue(withIdentifier: kAddIngredientSegueID, sender: self.recipe)
		}
	}
	
	
	//MARK: - Moving rows
	
	// Override to support conditional rearranging of the table view.
	override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
		
		var canMove: Bool = false
		// Moves are only allowed within the ingredients section.  Within the ingredients section, the last row (Add Ingredient) cannot be moved.
		if (indexPath.section == Section.ingredients.rawValue) {
			canMove = indexPath.row != self.recipe.ingredients?.count
		}
		return canMove;
	}
	
	override func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
		
		var target = proposedDestinationIndexPath
		
		// Moves are only allowed within the ingredients section, so make sure the destination
		// is in the ingredients section. If the destination is in the ingredients section,
		// make sure that it's not the Add Ingredient row -- if it is, retarget for the penultimate row.
		//
		let proposedSection = proposedDestinationIndexPath.section
		
		if proposedSection < Section.ingredients.rawValue {
			target = IndexPath(row: 0, section: Section.ingredients.rawValue)
		}
		else if proposedSection > Section.ingredients.rawValue {
			target = IndexPath(row: self.recipe.ingredients!.count - 1, section: Section.ingredients.rawValue)
		}
		else {
			let ingredientsCount_1 = self.recipe.ingredients!.count - 1
			
			if proposedDestinationIndexPath.row > ingredientsCount_1 {
				target = IndexPath(row: ingredientsCount_1, section: Section.ingredients.rawValue)
			}

		}
		
		return target

	}
	
	// Override to support rearranging the table view.
	override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
		
		/*
		Update the ingredients array in response to the move.
		Update the display order indexes within the range of the move.
		*/
		var ingredient = self.ingredients[fromIndexPath.row]
		self.ingredients.remove(at: fromIndexPath.row)
		self.ingredients.insert(ingredient, at: to.row)
		
		var start = fromIndexPath.row
		if to.row < start {
			start = to.row
		}
		
		var end = to.row
		if fromIndexPath.row > end {
			end = fromIndexPath.row
		}

		for i in start...end {
			ingredient = self.ingredients[i]
			ingredient.displayOrder = Int16(i)
		}

	}
	
	//MARK: - Photo
	@IBAction func photoTapped() {
		
		// If in editing state, then display an image picker; if not, create and push a photo view controller.
		if self.isEditing {
			let imagePicker = UIImagePickerController()
			imagePicker.delegate = self
			self.present(imagePicker, animated: true, completion: nil)
		} else {
			let recipePhotoViewController = RecipePhotoViewController()
			recipePhotoViewController.hidesBottomBarWhenPushed = true
			recipePhotoViewController.recipe = self.recipe
			self.show(recipePhotoViewController, sender: self)
		}

	}
	
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
		
		let selectedImage = info[UIImagePickerControllerOriginalImage] as! UIImage

		
		// Delete any existing image.
		let oldImage = self.recipe.image
		if oldImage != nil {
			self.recipe.managedObjectContext?.delete(oldImage!)
		}
		
		// Create an image object for the new image.
		let image = NSEntityDescription.insertNewObject(forEntityName: "image", into: self.recipe.managedObjectContext!) as! Image

		self.recipe.image = image
		
		// Set the image for the image managed object.
		image.setValue(selectedImage, forKey: "image")
		
		// Create a thumbnail version of the image for the recipe object.
		let size = selectedImage.size
		var ratio: CGFloat = 0.0
		if size.width > size.height {
			ratio = 44.0 / size.width
		}
		else {
			ratio = 44.0 / size.height
		}
		let rect = CGRect(x: 0.0, y: 0.0, width: ratio*size.width, height: ratio*size.height)
		
		UIGraphicsBeginImageContext(rect.size)
		selectedImage.draw(in: rect)
		self.recipe.thumbnailImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext();
		picker.dismiss(animated: true, completion: nil)
	}
	
	func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		picker.dismiss(animated: true, completion: nil)
	}
	
	func updatePhotoButton() {
		
		/*
		How to present the photo button depends on the editing state and whether the recipe has a thumbnail image.
		* If the recipe has a thumbnail, set the button's highlighted state to the same as the editing state (it's highlighted if editing).
		* If the recipe doesn't have a thumbnail, then: if editing, enable the button and show an image that says "Choose Photo" or similar; if not editing then disable the button and show nothing.
		*/
		let isEditing = self.isEditing
		
		if self.recipe.thumbnailImage != nil {
			self.photoButton.isHighlighted = isEditing
		}
		else {
			self.photoButton.isEnabled = isEditing
			
			if isEditing {
				self.photoButton.setImage(UIImage(named: "choosePhoto"), for: .normal)
			}
			else {
				self.photoButton.setImage(nil, for: .normal)
			}
		}
	}
	
}
