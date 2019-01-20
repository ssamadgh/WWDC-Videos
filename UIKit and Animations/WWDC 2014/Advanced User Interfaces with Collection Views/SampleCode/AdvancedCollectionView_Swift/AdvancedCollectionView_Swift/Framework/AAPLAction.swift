/*
Copyright (C) 2015 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
A simple object that represents an action that might be associated with a cell or used in a data source to present a series of buttons.
*/

import Foundation

/// A generic object wrapping a localized title and a selector.
class AAPLAction: NSObject {
	
	/// Is the action destructive? Destructive actions will be rendered using the theme's destructiveActionColor property.
	var isDestructive: Bool!

	/// The title of the action.
    var title: String!
	
	/// The selector sent up the responder chain when this action is invoked.
    var selector: Selector!
	
	/// Create an AAPLAction instance with the given title and selector.
	class func action(withTitle title: String, selector: Selector) -> AAPLAction {
		let action = AAPLAction()
		action.title = title
		action.selector = selector
		return action
	}

	/// Create an AAPLAction instance that is destructive and has the given title and selector.
	class func destructiveAction(withTitle title: String, selector: Selector) -> AAPLAction {
		let action = AAPLAction()
		action.title = title
		action.selector = selector
		action.isDestructive = true
		return action
	}

}



