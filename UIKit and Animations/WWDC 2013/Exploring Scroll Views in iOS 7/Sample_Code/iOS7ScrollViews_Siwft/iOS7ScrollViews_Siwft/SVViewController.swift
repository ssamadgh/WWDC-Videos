//
//  ViewController.swift
//  iOS7ScrollViews_Siwft
//
//  Created by Seyed Samad Gholamzadeh on 7/7/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

class SVViewController: UIViewController, UICollectionViewDataSource, SVScrollingCellDelegate {

	let cellIdentifier = "CellIdentifier"
	
	@IBOutlet weak var scrollView: UIScrollView!
	@IBOutlet weak var otherView: UIView!
	@IBOutlet weak var collectionView: UICollectionView!
	@IBOutlet weak var flowLayout: SpringyFlowLayout!

	var random: CGFloat {
		return CGFloat(arc4random_uniform(UInt32(RAND_MAX)))/CGFloat(RAND_MAX)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		self.collectionView.register(SVScrollingCell.self, forCellWithReuseIdentifier: cellIdentifier)
		
		let width = UIScreen.main.bounds.width

//		let flowLayout = UICollectionViewFlowLayout()
		flowLayout.itemSize = CGSize(width: width, height: 50)
		flowLayout.sectionInset = .zero
		self.collectionView.collectionViewLayout = flowLayout
		self.otherView.frame.size.width = width
		self.otherView.frame.origin.x = width
		self.scrollView.contentSize = CGSize(width: 2*width, height: self.view.frame.size.height)
	}

	//MARK: - SVScrollingCellDelegate
	
	func scrollingCellDidBeginPulling(_ cell: SVScrollingCell) {
		self.scrollView.isScrollEnabled = false
		self.otherView.backgroundColor = cell.color
	}
	
	func scrolling(_ cell: SVScrollingCell, didChangePullOffset offset: CGFloat) {
		self.scrollView.contentOffset = CGPoint(x: offset, y: 0)
	}
	
	func scrollingCellDidEndPulling(_ cell: SVScrollingCell) {
		self.scrollView.isScrollEnabled = true
	}
	
	//MARK: - UICollectionViewDatasource methods
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return 80
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! SVScrollingCell
		cell.delegate = self
		
		let red: CGFloat = self.random
		let green: CGFloat = self.random
		let blue: CGFloat = self.random
		cell.color = UIColor(red: red, green: green, blue: blue, alpha: 1)
		
		return cell
	}
	

}

