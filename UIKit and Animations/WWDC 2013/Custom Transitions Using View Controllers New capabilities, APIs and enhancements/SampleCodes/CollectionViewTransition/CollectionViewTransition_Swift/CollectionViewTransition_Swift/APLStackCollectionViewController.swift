//
//  APLStackCollectionViewController.swift
//  CollectionViewTransition_Swift
//
//  Created by Seyed Samad Gholamzadeh on 6/30/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//  Abstract: The UICollectionViewController containing the custom stack layout.


import UIKit

class APLStackCollectionViewController: APLCollectionViewController {

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		// NOTE: the following line of code is necessary to work around a bug in UICollectionView,
		// when you transition back to this view controller from a pinch inward gesture,
		// the z-ordering of the stacked photos may be wrong.
		//
		self.collectionView?.reloadData()
	}
	
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		// user tapped a stack of photos, navigate the grid layout view controller
		self.navigationController?.pushViewController(self.nextViewController(at: .zero), animated: true)
	}

	// obtain the next collection view controller based on where the user tapped in case there are multiple stacks
	override func nextViewController(at point: CGPoint) -> UICollectionViewController {
		// we could have multiple section stacks, so we need to find the right one
		let grid = UICollectionViewFlowLayout()

		grid.itemSize = CGSize(width: 75.0, height: 75.0)
		grid.sectionInset = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
		
		let nextCollectionViewController = APLGridCollectionViewController(collectionViewLayout: grid)
		
		// Set "useLayoutToLayoutNavigationTransitions" to YES before pushing a a
		// UICollectionViewController onto a UINavigationController. The top view controller of
		// the navigation controller must be a UICollectionViewController that was pushed with
		// this property set to NO. This property should NOT be changed on a UICollectionViewController
		// that has already been pushed onto a UINavigationController.
		//
		nextCollectionViewController.useLayoutToLayoutNavigationTransitions = true
		
		nextCollectionViewController.title = "Grid Layout";
		
		return nextCollectionViewController
	}
}
