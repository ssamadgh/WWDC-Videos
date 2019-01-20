//
//  PhotoEditorViewController.swift
//  Running with a Snap - Swift
//
//  Created by Seyed Samad Gholamzadeh on 7/14/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

private let reuseIdentifier = "PhotoEditorCell"

class PhotoEditorViewController: UICollectionViewController, UIViewControllerTransitioningDelegate {

	var run: Run!
	var userDeletedPhoto: Bool = false
	
	init() {
		let flowLayout = UICollectionViewFlowLayout()
		flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
		flowLayout.itemSize = Run.previewPhotoSize
		super.init(collectionViewLayout: flowLayout)
		
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.navigationItem.title = "\(self.run.numberOfPhotos) photos"
	}
	
	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.register(PhotoEditorCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return self.run.numberOfPhotos
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PhotoEditorCollectionViewCell
		cell.imageView.image = self.run.photo(at: indexPath.item, of: .preview)
		
        return cell
    }
	
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let vc  = EditPhotoViewController(nibName: nil, bundle: nil)
		vc.run = self.run
		vc.photoIndex = indexPath.row
		vc.deletionCallback = { photoIndex in
			self.userDeletedPhoto = true
			try? self.run.deletePhoto(at: photoIndex)
			self.dismiss(animated: true, completion: {
				collectionView.deleteItems(at: [indexPath])
			})
		}

		vc.transitioningDelegate = self
		vc.modalPresentationStyle = .custom
		self.navigationController?.present(vc, animated: true, completion: nil)
	}
	
	func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		if self.userDeletedPhoto {
			return DeletePhotoAnimator()
		}
		else {
			let animator = PresentPhotoAnimator()
			animator.isPresenting = false
			return animator
		}
	}
	
	func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		let animator = PresentPhotoAnimator()
		animator.isPresenting = (presented is EditPhotoViewController)
		return animator
	}
	
}

class PhotoEditorCollectionViewCell: UICollectionViewCell {
	var imageView: UIImageView!
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		var r = CGRect.zero
		r.size = Run.previewPhotoSize
		self.imageView = UIImageView(frame: r)
		self.imageView.contentMode = .scaleAspectFit
		
		self.contentView.addSubview(self.imageView)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}




