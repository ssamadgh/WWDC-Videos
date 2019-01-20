/*
Copyright (C) 2014 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:

A view controller that shows placeholder text.

*/

import UIKit

class AAPLEmptyViewController: UIViewController {

	override func loadView() {
		super.loadView()
		
		let view = UIView()
		view.backgroundColor = .white
		self.view = view

		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.text = NSLocalizedString("No Conversation Selected", comment: "No Conversation Selected")
		label.textColor = UIColor(white: 0.0, alpha: 0.4)
		label.font = UIFont.preferredFont(forTextStyle: .headline)
		view.addSubview(label)
		
		self.view.addConstraint(NSLayoutConstraint(item: label, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1.0, constant: 0.0))
		self.view.addConstraint(NSLayoutConstraint(item: label, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1.0, constant: 0.0))

	}
}
