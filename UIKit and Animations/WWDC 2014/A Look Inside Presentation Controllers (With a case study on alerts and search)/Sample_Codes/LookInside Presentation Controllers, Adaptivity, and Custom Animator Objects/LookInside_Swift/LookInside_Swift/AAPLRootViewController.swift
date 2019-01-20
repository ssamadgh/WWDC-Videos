//
//  AAPLRootViewController.swift
//  LookInside_Swift
//
//  Created by Seyed Samad Gholamzadeh on 7/18/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

private let kNumberOfViews: Int = (37)
private let kViewsWide: CGFloat = (5)
private let kViewMargin: CGFloat = (2.0)

private let reuseIdentifier = "Cell"

class AAPLRootViewController: UICollectionViewController, UIAdaptivePresentationControllerDelegate {
	
	var coolSwitch: UISwitch!
	
	var transitionDelegate: UIViewControllerTransitioningDelegate!
	
	var presentationShouldBeAwesome: Bool {
		return self.coolSwitch.isOn
	}
	
	init() {
		let layout = UICollectionViewFlowLayout()
		super.init(collectionViewLayout: layout)
		self.configureTitleBar()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.collectionView!.register(AAPLPhotoCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
		self.collectionView?.backgroundColor = nil
		
		let layout = self.collectionViewLayout as! UICollectionViewFlowLayout
		layout.minimumInteritemSpacing = kViewMargin
		layout.minimumLineSpacing = kViewMargin
		self.configureLayouItemSize()
	}
	
	
	// MARK: UICollectionViewDataSource
	
	override func numberOfSections(in collectionView: UICollectionView) -> Int {
		// #warning Incomplete implementation, return the number of sections
		return 1
	}
	
	
	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		// #warning Incomplete implementation, return the number of items
		return kNumberOfViews
	}
	
	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! AAPLPhotoCollectionViewCell
		let photoName = "\(indexPath.item)"
		let photo = UIImage(named: photoName)
		cell.image = photo
		return cell
	}
	
	// MARK: UICollectionViewDelegate
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let overlay = AAPLOverlayViewController()
		
		if self.presentationShouldBeAwesome {
			self.transitionDelegate = AAPLCoolTransitioningDelegate()
		}
		else {
			self.transitionDelegate = AAPLOverlayTransitioningDelegate()
		}
		
		overlay.transitioningDelegate = self.transitionDelegate
		
		let pc = overlay.presentationController
		pc!.delegate = self
		
		let selectedCell = collectionView.cellForItem(at: indexPath) as! AAPLPhotoCollectionViewCell
		overlay.photoView = selectedCell
		self.present(overlay, animated: true, completion: nil)
	}
	
	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)
		
		self.configureLayouItemSize(for: size)
	}
		
	func configureLayouItemSize(for size: CGSize? = nil) {
		let size = size ?? self.view.bounds.size
		var itemWidth = size.width / kViewsWide
		itemWidth -= kViewMargin
		(self.collectionViewLayout as! UICollectionViewFlowLayout).itemSize = CGSize(width: itemWidth, height: itemWidth)
		self.collectionViewLayout.invalidateLayout()
	}
	
	override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
		return .all
	}
	
	func configureTitleBar() {
		self.title = NSLocalizedString("LookInside Photos", comment: "App Title")
		self.edgesForExtendedLayout = UIRectEdge(rawValue: UIRectEdge.left.rawValue | UIRectEdge.bottom.rawValue | UIRectEdge.right.rawValue)
		self.coolSwitch = UISwitch()
		self.coolSwitch.onTintColor = .purple
		self.coolSwitch.tintColor = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.2)
		
		let enablecoolBarButtonItem = UIBarButtonItem(customView: self.coolSwitch)
		self.navigationItem.leftBarButtonItem = enablecoolBarButtonItem
	}
	
	func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
		return .overFullScreen
	}
	
	
}
