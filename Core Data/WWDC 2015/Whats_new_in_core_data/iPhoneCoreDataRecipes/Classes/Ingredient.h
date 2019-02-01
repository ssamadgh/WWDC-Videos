/*
 Copyright (C) 2017 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 Model class to represent an ingredient.
 */

@class Recipe;

@interface Ingredient : NSManagedObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *amount;
@property (nonatomic, strong) Recipe *recipe;
@property (nonatomic, strong) NSNumber *displayOrder;

@end



