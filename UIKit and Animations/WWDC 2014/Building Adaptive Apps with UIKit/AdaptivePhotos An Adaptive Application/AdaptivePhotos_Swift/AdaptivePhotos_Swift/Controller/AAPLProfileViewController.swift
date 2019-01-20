/*
Copyright (C) 2014 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:

A view controller that shows a user's profile.
*/

import UIKit

class AAPLProfileViewController: UIViewController {

	var user: AAPLUser! {
		didSet {
			if self.isViewLoaded {
				self.updateUser()
			}
		}
	}
	
	var nameText: String {
		return self.user.name
	}
	
	var conversationsText: String {
		return String(format: NSLocalizedString("%ld conversations", comment: "%ld conversations"), self.user.conversations.count)
	}
	
	var photosText: String {
		var photoCount = 0
		for conversation in self.user.conversations {
			photoCount += conversation.photos.count
		}
		return String(format: NSLocalizedString("%ld photos", comment: "%ld photos"), photoCount)

	}
	
	var imageView: UIImageView!
	var nameLabel: UILabel!
	var conversationsLabel: UILabel!
	var photosLabel: UILabel!
	
	var constraints: [NSLayoutConstraint]!
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
//	}
//	override func viewDidLoad() {
//		super.viewDidLoad()
//	}
//	override func loadView() {
//		super.loadView()
		
		let view = UIView()
		view.backgroundColor = .white
		
		self.imageView = UIImageView()
		self.imageView.contentMode = .scaleAspectFit
		self.imageView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(self.imageView)
		
		self.nameLabel = UILabel()
		self.nameLabel.font = UIFont.preferredFont(forTextStyle: .headline)
		self.nameLabel.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(self.nameLabel)
		
		self.conversationsLabel = UILabel()
		self.conversationsLabel.font = UIFont.preferredFont(forTextStyle: .body)
		self.conversationsLabel.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(self.conversationsLabel)
		
		self.photosLabel = UILabel()
		self.conversationsLabel.font = UIFont.preferredFont(forTextStyle: .body)
		self.photosLabel.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(self.photosLabel)
		
		self.view = view
		self.updateUser()
		self.updateConstraint(for: self.traitCollection)
	}

	func updateConstraint(for collection: UITraitCollection) {
		
		let views = ["topLayoutGuide" : self.topLayoutGuide, "imageView" : self.imageView, "nameLabel" : self.nameLabel, "conversationsLabel" : self.conversationsLabel, "photosLabel" : self.photosLabel] as [String : Any]
		
		var newConstraints: [NSLayoutConstraint] = []
		
		if collection.verticalSizeClass == .compact {
			newConstraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "|[imageView]-[nameLabel]-|", options: NSLayoutFormatOptions(), metrics: nil, views: views))
			newConstraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "[imageView]-[conversationsLabel]-|", options: NSLayoutFormatOptions(), metrics: nil, views: views))
			newConstraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "[imageView]-[photosLabel]-|", options: NSLayoutFormatOptions(), metrics: nil, views: views))
			newConstraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:|[topLayoutGuide]-[nameLabel]-[conversationsLabel]-[photosLabel]", options: NSLayoutFormatOptions(), metrics: nil, views: views))
			newConstraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:|[topLayoutGuide][imageView]|", options: NSLayoutFormatOptions(), metrics: nil, views: views))
			newConstraints.append(NSLayoutConstraint(item: self.imageView, attribute: .width, relatedBy: .equal, toItem: self.view, attribute: .width, multiplier: 0.5, constant: 0.0))
		}
		else {
			newConstraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "|[imageView]|", options: NSLayoutFormatOptions(), metrics: nil, views: views))
			newConstraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "|-[nameLabel]-|", options: NSLayoutFormatOptions(), metrics: nil, views: views))
			newConstraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "|-[conversationsLabel]-|", options: NSLayoutFormatOptions(), metrics: nil, views: views))
			newConstraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "|-[photosLabel]-|", options: NSLayoutFormatOptions(), metrics: nil, views: views))
			newConstraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:[topLayoutGuide]-[nameLabel]-[conversationsLabel]-[photosLabel]-20-[imageView]|", options: NSLayoutFormatOptions(), metrics: nil, views: views))
		}
		
		if self.constraints != nil {
			self.view.removeConstraints(self.constraints)
		}
		self.constraints = newConstraints
		self.view.addConstraints(self.constraints!)
		
	}
	
	override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
		super.willTransition(to: newCollection, with: coordinator)
		
		coordinator.animate(alongsideTransition: { (context) in
			self.updateConstraint(for: newCollection)
			self.view.setNeedsLayout()

		}, completion: nil)
	}
	
	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		
		self.title = NSLocalizedString("Profile", comment: "Profile")
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func updateUser() {
		self.nameLabel.text = self.nameText
		self.conversationsLabel.text = self.conversationsText
		self.photosLabel.text = self.photosText
		
		self.imageView.image = self.user.lastPhoto.image
	}
	
}
