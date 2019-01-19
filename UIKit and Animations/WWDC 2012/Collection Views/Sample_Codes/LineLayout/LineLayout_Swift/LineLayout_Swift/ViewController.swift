//
//  ViewController.swift
//  LineLayout_Swift
//
//  Created by Seyed Samad Gholamzadeh on 4/30/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

class ViewController: UICollectionViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		self.collectionView?.backgroundColor = .clear
//		self.view.backgroundColor = .yellow
		self.collectionView?.register(Cell.self, forCellWithReuseIdentifier: "cell")
	}
	
	override func numberOfSections(in collectionView: UICollectionView) -> Int {
		return 1
	}

	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return 60
	}
	
	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! Cell
		cell.label.text = "\(indexPath.item)"
		return cell
	}
	
	

}

