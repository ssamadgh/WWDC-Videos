/*
 Copyright (C) 2015 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 A simple object that represents an action that might be associated with a cell or used in a data source to present a series of buttons.
 */

@import Foundation;

NS_ASSUME_NONNULL_BEGIN




/// A generic object wrapping a localized title and a selector.
@interface AAPLAction : NSObject

/// Create an AAPLAction instance with the given title and selector.
+ (instancetype)actionWithTitle:(NSString *)title selector:(SEL)selector;

/// Create an AAPLAction instance that is destructive and has the given title and selector.
+ (instancetype)destructiveActionWithTitle:(NSString *)title selector:(SEL)selector;

/// Is the action destructive? Destructive actions will be rendered using the theme's destructiveActionColor property.
@property (nonatomic, readonly, getter = isDestructive) BOOL destructive;

/// The title of the action.
@property (nonatomic, readonly, copy) NSString *title;

/// The selector sent up the responder chain when this action is invoked.
@property (nonatomic, readonly) SEL selector;

@end




NS_ASSUME_NONNULL_END
