//
//  ViewController.swift
//  CircleLayout_Swift
//
//  Created by Seyed Samad Gholamzadeh on 5/1/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

class ViewController: UICollectionViewController {

	var cellCount: Int!

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		self.cellCount = 20
		let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
		self.collectionView?.addGestureRecognizer(tapRecognizer)
		self.collectionView?.register(Cell.self, forCellWithReuseIdentifier: "cell")
		self.collectionView?.reloadData()
		self.collectionView?.backgroundColor = UIColor.groupTableViewBackground
		
	}
	
	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return self.cellCount
	}

	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
		return cell
	}

	@objc func handleTapGesture( _ sender: UITapGestureRecognizer) {
		if sender.state == .ended {
			let initialPinchPoint = sender.location(in: self.collectionView)
			let tappedCellPath = self.collectionView?.indexPathForItem(at: initialPinchPoint)
			if tappedCellPath != nil {
				self.cellCount! -= 1

				self.collectionView?.performBatchUpdates({
					self.collectionView?.deleteItems(at: [tappedCellPath!])
				}, completion: nil)
			}
			else {
				self.cellCount! += 1

				self.collectionView?.performBatchUpdates({
					self.collectionView?.insertItems(at: [IndexPath(item: 0, section: 0)])
				}, completion: nil)
			}
		}
	}

}

