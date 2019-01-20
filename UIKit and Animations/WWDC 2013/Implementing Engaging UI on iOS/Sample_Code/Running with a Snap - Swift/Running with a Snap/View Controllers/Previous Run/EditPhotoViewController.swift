//
//  EditPhotoViewController.swift
//  Running with a Snap - Swift
//
//  Created by Seyed Samad Gholamzadeh on 7/14/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

class EditPhotoViewController: UIViewController {

	@IBOutlet weak var imageView: UIImageView!
	
	var run: Run!
	var photoIndex: Int!
	var deletionCallback: ((_ photoIndex: Int) -> ())!
	
	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		
		self.modalPresentationStyle = .pageSheet
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(closePhoto(_:)))
		self.view.addGestureRecognizer(tapGesture)
		self.imageView.image = self.run.photo(at: self.photoIndex, of: .original)
    }
	
	@IBAction func optionsTapped(_ sender: Any) {
		let selectedIndex = (sender as! UISegmentedControl).selectedSegmentIndex
		
		if selectedIndex == 0 {
			// background
			(appDelegate as! AppDelegate).interfaceManager.backgroundImage = self.imageView.image
			let checkImage = UIImage(named: "check_template")
			let templatedCheckImage = checkImage?.withRenderingMode(.alwaysTemplate)
			let success = UIImageView(image: templatedCheckImage)
			success.contentMode = .center
			success.frame = self.view.bounds
			
			self.view.addSubview(success)
			UIView.animate(withDuration: 0.50, delay: 0.50, options: .curveLinear, animations: {
				success.alpha = 0.0
			}) { (finished) in
				success.removeFromSuperview()
			}
		}
		else {
			// delete
			if self.deletionCallback != nil {
				self.deletionCallback!(self.photoIndex)
			}
			else {
				try? self.run.deletePhoto(at: self.photoIndex)
				self.dismiss(animated: true, completion: nil)
			}
		}
	}

	@objc func closePhoto(_ tapGesture: UITapGestureRecognizer) {
		self.dismiss(animated: true, completion: nil)
	}
}
