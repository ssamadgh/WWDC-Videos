//
//  CollectionViewController.swift
//  CollectionViewTraining_1_from_Scratch
//
//  Created by Seyed Samad Gholamzadeh on 7/3/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class CollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSourcePrefetching {
	
	let sizesWidth: [CGFloat] = [50, 30, 40, 22, 15, 78, 95, 66, 22]
    override func viewDidLoad() {
        super.viewDidLoad()
		self.collectionView!.backgroundColor = .yellow
		
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.register(CollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
		
		/*
		rinting description of kind:
		"UICollectionElementKindSectionFooter"
		Printing description of kind:
		"UICollectionElementKindSectionHeader"
		*/
		self.collectionView?.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "header")
        // Do any additional setup after loading the view.
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return 100
    }
	
	override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
		let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath)
		view.backgroundColor = .green
		return view
	}

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CollectionViewCell
		let remain = CGFloat(indexPath.item).truncatingRemainder(dividingBy: 2)
		cell.contentView.backgroundColor = remain == 0 ? .red : .blue
		
        // Configure the cell
    
        return cell
    }
	
	func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
		
	}
	
	func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
		
	}
	
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		
//		let newLayout = UICollectionViewFlowLayout()
//		newLayout.minimumLineSpacing = 0
//		newLayout.minimumInteritemSpacing = 0
//		let width = UIScreen.main.bounds.width/CGFloat(indexPath.item+1)
//		newLayout.itemSize = CGSize(width: width, height: width)
		
		let newLayout = APLStackLayout()
		
		collectionView.setCollectionViewLayout(newLayout, animated: true)
		
		
//		let cell = collectionView.cellForItem(at: indexPath)
//		UIView.animate(withDuration: 0.05, delay: 0, options: [.repeat, .autoreverse], animations: {
//			cell?.transform = CGAffineTransform.init(rotationAngle: 5*CGFloat.pi/180)
//
//		}, completion: nil)
//		collectionView.selectItem(at: indexPath, animated: true, scrollPosition: UICollectionViewScrollPosition.centeredVertically)
//		cell?.isHighlighted = true
	}
	
//	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//
//		let width: CGFloat = self.sizesWidth[Int(arc4random_uniform(UInt32(self.sizesWidth.count-1)))]
//		
//		return CGSize(width: width, height: width)
//	}

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */
	

}
