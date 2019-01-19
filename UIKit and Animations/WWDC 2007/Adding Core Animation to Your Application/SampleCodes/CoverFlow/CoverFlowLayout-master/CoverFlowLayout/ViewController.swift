//
//  ViewController.swift
//  CoverFlowLayout
//
//  Created by Broccoli on 15/11/26.
//  Copyright © 2015年 Broccoli. All rights reserved.
//

import UIKit

class ViewController: UICollectionViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

private let CellIdentifier = "CollectionCell"
extension ViewController {
	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 30
    }
	

	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier, for: indexPath as IndexPath)
        cell.backgroundColor = UIColor(red: CGFloat(arc4random() % 255) / 255.0, green: CGFloat(arc4random() % 255) / 255.0, blue: CGFloat(arc4random() % 255) / 255.0, alpha: 1.0)
        cell.layer.allowsEdgeAntialiasing = true
        return cell
    }
}
