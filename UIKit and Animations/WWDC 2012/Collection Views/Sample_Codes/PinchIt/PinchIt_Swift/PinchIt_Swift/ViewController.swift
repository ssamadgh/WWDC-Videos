//
//  ViewController.swift
//  PinchIt_Swift
//
//  Created by Seyed Samad Gholamzadeh on 5/19/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

class ViewController: UICollectionViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		
		let pinchRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchGesture(_:)))
		self.collectionView?.addGestureRecognizer(pinchRecognizer)
		self.collectionView?.register(Cell.self, forCellWithReuseIdentifier: "cell")
	}

	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return 63
	}
	
	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
		return cell
	}

	@objc func handlePinchGesture( _ sender: UIPinchGestureRecognizer) {
		let pinchLayout = self.collectionView?.collectionViewLayout as! PinchLayout
		
		if sender.state == .began {
			let initialPinchPoint = sender.location(in: self.collectionView)
			let pinchedCellPath = self.collectionView?.indexPathForItem(at: initialPinchPoint)
			pinchLayout.pinchedCellPath = pinchedCellPath
		}
		else if sender.state == .changed {
			pinchLayout.pinchedCellScale = sender.scale
			pinchLayout.pinchedCellCenter = sender.location(in: self.collectionView)
			
		}
		else {
			self.collectionView?.performBatchUpdates({
				pinchLayout.pinchedCellPath = nil
				pinchLayout.pinchedCellScale = 1.0
			}, completion: nil)
		}
		
	}
}

