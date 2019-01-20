//
//  APLGridCollection.swift
//  CollectionViewTransition_Swift
//
//  Created by Seyed Samad Gholamzadeh on 6/30/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

class APLGridCollectionViewController: APLCollectionViewController {

	
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		
		// used tapped a collection view cell, navigate to a detail view controller showing that single photo
		let cell = collectionView.cellForItem(at: indexPath) as! APLCollectionViewCell
		if cell.imageView.image != nil {
			
			// we need to load the main storyboard because this view controller was created programmatically
			let storyboard = UIStoryboard(name: "Main", bundle: nil)
			let detailViewController = storyboard.instantiateViewController(withIdentifier: "detailVC") as! APLDetailViewController
			detailViewController.image = cell.imageView.image
			self.navigationController?.pushViewController(detailViewController, animated: true)
		}

	}
}
