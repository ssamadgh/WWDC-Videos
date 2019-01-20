//
//  APLCollectionViewController.swift
//  CollectionViewTransition_Swift
//
//  Created by Seyed Samad Gholamzadeh on 6/30/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.

// Abstract: Base UICollectionViewController containing the basic functionality for collection views.


import UIKit

let USE_IMAGES: Bool =   true  // if 1 images are used for each cell, if 0 we use varying UIColors swatches for each cell

let MAX_COUNT: Int =   24
let CELL_ID: String =     "CELL_ID"

class APLCollectionViewController: UICollectionViewController {

	override init(collectionViewLayout layout: UICollectionViewLayout) {
		super.init(collectionViewLayout: layout)
		
		// make sure we know about our cell prototype so dequeueReusableCellWithReuseIdentifier can work
		self.collectionView!.register(APLCollectionViewCell.self, forCellWithReuseIdentifier: CELL_ID)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return MAX_COUNT
    }
	
	func nextViewController(at point: CGPoint) -> UICollectionViewController? {
		return nil  // subclass must override this method
	}

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CELL_ID, for: indexPath) as! APLCollectionViewCell

		if USE_IMAGES {
			// set the cell to use an image
			let image = UIImage(named: "sa\(indexPath.item)")
			cell.imageView.image = image
		}
		else {
			// set the cell to use a color swatch
			let hue: CGFloat = CGFloat(indexPath.item/MAX_COUNT)
			let cellColor: UIColor = UIColor(hue: hue, saturation: 1.0, brightness: 1.0, alpha: 1.0)
			cell.contentView.backgroundColor = cellColor
		}
		
        return cell
    }

	override func collectionView(_ collectionView: UICollectionView, transitionLayoutForOldLayout fromLayout: UICollectionViewLayout, newLayout toLayout: UICollectionViewLayout) -> UICollectionViewTransitionLayout {
		let myCustomTransitionLayout = APLTransitionLayout(currentLayout: fromLayout, nextLayout: toLayout)
		return myCustomTransitionLayout
	}
	
}
