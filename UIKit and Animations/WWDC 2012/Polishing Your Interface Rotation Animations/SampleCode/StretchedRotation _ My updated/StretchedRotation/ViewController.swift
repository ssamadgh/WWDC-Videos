//
//  ViewController.swift
//  StretchedRotation
//
//  Created by Seyed Samad Gholamzadeh on 4/27/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

func captureSnapshot(of targetView: UIView) -> UIImageView {
	UIGraphicsBeginImageContextWithOptions(targetView.bounds.size, true, 0)
	UIGraphicsGetCurrentContext()!.translateBy(x: -targetView.bounds.origin.x, y: -targetView.bounds.origin.y)
	targetView.layer.render(in: UIGraphicsGetCurrentContext()!)
	let image = UIGraphicsGetImageFromCurrentImageContext()
	UIGraphicsEndImageContext()
	
	let snapshotView = UIImageView(image: image)
	snapshotView.frame = targetView.frame
	return snapshotView
}

extension UIView {
	
	func setFramePreserveHeight(_ frame: CGRect) {
		let height: CGFloat = self.bounds.height
		self.frame = frame
		self.frame.size.height = height
	}

}

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
	
	@IBOutlet weak var tableView: UITableView!
	
	@IBOutlet var navigationBar: UINavigationBar!
	@IBOutlet var tabBar: UITabBar!
	
	var frameBeforeRotation: CGRect!
	var frameAfterRotation: CGRect!

	var snapshotBeforeRotation: UIView!
	var snapshotAfterRotation: UIView!
	

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		self.tableView.rowHeight = 88
		
	}
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 30
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
//		cell.textLabel?.text = "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut"
		cell.textLabel?.text = "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut"

		cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
		cell.textLabel?.numberOfLines = 2
		cell.accessoryType = .disclosureIndicator
		return cell
	}
	
	
	override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
		coordinator.animate(alongsideTransition: { (context) in
			self.snapshotBeforeRotation = self.view.snapshotView(afterScreenUpdates: true)
			UIView.setAnimationsEnabled(false)
			self.snapshotBeforeRotation.transform = CGAffineTransform(rotationAngle: .pi/2)
			UIView.setAnimationsEnabled(true)

			self.view.insertSubview(self.snapshotBeforeRotation, aboveSubview: self.tableView)
			self.layout(self.snapshotBeforeRotation)
			self.tableView.isHidden = true
			self.snapshotBeforeRotation.alpha = 0
			
		}) { (context) in
			self.tableView.isHidden = false
			self.snapshotBeforeRotation.removeFromSuperview()
			self.snapshotBeforeRotation = nil
		}
	}
	
	
	
	func layout(_ view: UIView) {
		
		NSLayoutConstraint.activate([
			view.topAnchor.constraint(equalTo: self.view.topAnchor),
			view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
			view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
			view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
			])
	}
//	override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
//		print("tableView Before", self.tableView.frame)
//
//		self.frameBeforeRotation = view.frame
////		self.snapshotBeforeRotation = captureSnapshot(of: tableView)
//		self.snapshotBeforeRotation = self.view.snapshotView(afterScreenUpdates: true)
//		self.view.insertSubview(self.snapshotBeforeRotation, aboveSubview: tableView)
//
//
//		self.tabBar.invalidateIntrinsicContentSize()
//
//	}
//
//	override func willAnimateRotation(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
//		print("tableView After", self.tableView.frame)
//
//		self.frameAfterRotation = view.frame
//
//		let unstretchedArea: UIEdgeInsets = self.unstretchedInsets(for: tableView)
//
//		UIView.setAnimationsEnabled(false)
//
////		self.snapshotAfterRotation = captureSnapshot(of: tableView)
//		self.snapshotAfterRotation = self.view.snapshotView(afterScreenUpdates: true)
////		self.snapshotAfterRotation.setFramePreserveHeight(self.frameBeforeRotation)
//
//		print("unstretchedArea ", unstretchedArea)
////		var imageBeforeRotation: UIImage = (self.snapshotBeforeRotation as! UIImageView).image!
////		var imageAfterRotation: UIImage = (self.snapshotAfterRotation as! UIImageView).image!
////
////		imageBeforeRotation = imageBeforeRotation.resizableImage(withCapInsets: unstretchedArea)
//////		imageAfterRotation = imageAfterRotation.resizableImage(withCapInsets: unstretchedArea)
////
////		(self.snapshotBeforeRotation as! UIImageView).image = imageBeforeRotation
////		(self.snapshotAfterRotation as! UIImageView).image = imageAfterRotation
//
//		UIView.setAnimationsEnabled(true)
//
//		// pick the shorter iamge. fade it in or out
//		if self.snapshotAfterRotation.frame.size.height < self.snapshotBeforeRotation.frame.size.height {
//			self.snapshotAfterRotation.alpha = 0.0
//			self.view.insertSubview(self.snapshotAfterRotation, aboveSubview: self.snapshotBeforeRotation)
//			self.snapshotAfterRotation.alpha = 1.0
//		}
//		else {
//			self.view.insertSubview(self.snapshotAfterRotation, belowSubview: self.snapshotBeforeRotation)
//			self.self.snapshotBeforeRotation.alpha = 0.0
//		}
//
//		self.snapshotAfterRotation.frame = self.frameAfterRotation
//		self.snapshotBeforeRotation.setFramePreserveHeight(self.frameAfterRotation)
//
//		self.tableView.isHidden = true
//	}
//
//	override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
//		//AfterCompletionAnimation
//		self.snapshotBeforeRotation?.removeFromSuperview()
//		self.snapshotAfterRotation?.removeFromSuperview()
//		self.snapshotBeforeRotation = nil
//		self.snapshotAfterRotation = nil
//		self.tableView.isHidden = false
//	}
	
	
	
	func unstretchedInsets(for tableView: UITableView) -> UIEdgeInsets {
		var result = UIEdgeInsets.zero
		
		// find the right edge of the content view in the coordinate space of UITableView
		if let contentView = tableView.visibleCells.first?.contentView {
			let contentViewRightEdge = tableView.convert(CGPoint(x: contentView.bounds.width, y: 0), from: contentView).x
			let rightFixedWidth = tableView.bounds.width - contentViewRightEdge
			let leftFixedWidth = min(frameAfterRotation.width, frameBeforeRotation.width) - rightFixedWidth - 1
			result = UIEdgeInsets(top: 0, left: leftFixedWidth, bottom: 0, right: rightFixedWidth)
		}
		return result
	}
	
}

