//
//  ViewController.swift
//  SelfSizingCollectionView
//
//  Created by Compean on 08/01/15.
//  Copyright (c) 2015 Carlos Compean. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var array = ["Texto uno dos tres catorce quince I've set up a UICollectionView (with the default flow layout, and vertical scrolling) with custom cells that load from a xib. The cells contain a couple of elements (a UILabel and a UIView) with constraints on them. I've set up the constraints such that the cell height grows as the label text height increases using the new UICollectionViewFlowLayout property that's available in iOS8, estimatedItemSize: layout.estimatedItemSize = CGSizeMake(self.collectionView.frame.width, 100) Everything works like a charm except there's one big problem: the UICollectionView loads only half the items as returned by the numberOfItemsInSection method. So, when the method returns, say, 10, my UICollectionView only displays 5 cells (but displays and lays them out perfectly).", "3", "4", "5", "8", "Texto uno dos tres catorce quince I've set up a UICollectionView (with the default flow layout, and vertical scrolling) with custom cells that load from a xib. The cells contain a couple of elements (a UILabel and a UIView) with constraints on them. I've set up the constraints such that the cell height grows as the label text height increases using the new UICollectionViewFlowLayout property that's available in iOS8, estimatedItemSize: layout.estimatedItemSize = CGSizeMake(self.collectionView.frame.width, 100) Everything works like a charm except there's one big problem: the UICollectionView loads only half the items as returned by the numberOfItemsInSection method. So, when the method returns, say, 10, my UICollectionView only displays 5 cells (but displays and lays them out perfectly).", "Texto uno dos tres catorce quince I've set up a UICollectionView (with the default flow layout, and vertical scrolling) with custom cells that load from a xib. The cells contain a couple of elements (a UILabel and a UIView) with constraints on them. I've set up the constraints such that the cell height grows as the label text height increases using the new UICollectionViewFlowLayout property that's available in iOS8, estimatedItemSize: layout.estimatedItemSize = CGSizeMake(self.collectionView.frame.width, 100) Everything works like a charm except there's one big problem: the UICollectionView loads only half the items as returned by the numberOfItemsInSection method. So, when the method returns, say, 10, my UICollectionView only displays 5 cells (but displays and lays them out perfectly)."]

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        var cell = collectionView.dequeueReusableCellWithReuseIdentifier("cellTextView", forIndexPath: indexPath) as CustomTableViewCellWithTextView
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath as IndexPath) as! CustomCollectionViewCell
		cell.contentView.translatesAutoresizingMaskIntoConstraints = false
        cell.textLabel.text = array[indexPath.row]
//        cell.textView.text = array[indexPath.row]
        //cell.textView.sizeToFit()
        return cell
    }
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return array.count
    }
	
    override func viewDidLoad() {
        super.viewDidLoad()
		print("collection view section insets left: \((collectionView.collectionViewLayout as! UICollectionViewFlowLayout).sectionInset.left) right: \((collectionView.collectionViewLayout as! UICollectionViewFlowLayout).sectionInset.right) top: \((collectionView.collectionViewLayout as! UICollectionViewFlowLayout).sectionInset.top) bottom: \((collectionView.collectionViewLayout as! UICollectionViewFlowLayout).sectionInset.bottom)")
        print("collection view width : \(collectionView.frame.width)")
        print("view width : \(view.frame.width)")
        
		let flowLayout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        
		flowLayout.estimatedItemSize = CGSize(width: view.frame.width - 10, height: 400)
        flowLayout.minimumLineSpacing = 30
        //flowLayout.minimumInteritemSpacing = 20
        flowLayout.sectionInset = UIEdgeInsetsMake(10, 10, 0, 0)
        // Do any additional setup after loading the view, typically from a nib.
    }
    
	override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
        
        
        //collectionView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

