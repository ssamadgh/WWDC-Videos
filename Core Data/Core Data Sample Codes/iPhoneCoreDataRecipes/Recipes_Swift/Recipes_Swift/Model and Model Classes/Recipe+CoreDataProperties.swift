
/*
Recipe+CoreDataProperties.swift
Recipes_Swift

Created by Seyed Samad Gholamzadeh on 1/27/18.
Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.

Abstract:
Model class to represent a recipe.

*/


import CoreData
import UIKit

extension Recipe {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Recipe> {
        return NSFetchRequest<Recipe>(entityName: "Recipe")
    }

    @NSManaged public var instructions: String?
    @NSManaged public var name: String?
    @NSManaged public var overview: String?
    @NSManaged public var prepTime: String?
    @NSManaged public var thumbnailImage: UIImage?
    @NSManaged public var image: Image?
    @NSManaged public var ingredients: NSSet?
    @NSManaged public var type: RecipeType?

}

// MARK: Generated accessors for ingredients
extension Recipe {

    @objc(addIngredientsObject:)
    @NSManaged public func addToIngredients(_ value: Ingredient)

    @objc(removeIngredientsObject:)
    @NSManaged public func removeFromIngredients(_ value: Ingredient)

    @objc(addIngredients:)
    @NSManaged public func addToIngredients(_ values: NSSet)

    @objc(removeIngredients:)
    @NSManaged public func removeFromIngredients(_ values: NSSet)

}
