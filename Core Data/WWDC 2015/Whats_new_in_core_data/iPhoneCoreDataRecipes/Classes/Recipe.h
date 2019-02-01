/*
 Copyright (C) 2017 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 Model class to represent a recipe.
 */

@interface ImageToDataTransformer : NSValueTransformer
@end

@interface Recipe : NSManagedObject

@property (nonatomic, strong) NSString *instructions;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *overview;
@property (nonatomic, strong) NSString *prepTime;
@property (nonatomic, strong) NSSet *ingredients;
@property (nonatomic, strong) UIImage *thumbnailImage;

@property (nonatomic, strong) NSManagedObject *image;
@property (nonatomic, strong) NSManagedObject *type;

@end

@interface Recipe (CoreDataGeneratedAccessors)

- (void)addIngredientsObject:(NSManagedObject *)value;
- (void)removeIngredientsObject:(NSManagedObject *)value;
- (void)addIngredients:(NSSet *)value;
- (void)removeIngredients:(NSSet *)value;

@end

