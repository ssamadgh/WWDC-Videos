//
//  PreviousRunEditorMenuViewController.swift
//  Running with a Snap - Swift
//
//  Created by Seyed Samad Gholamzadeh on 7/13/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

class PreviousRunEditorMenuViewController: UIViewController {

	var run: Run!
	@IBOutlet weak var runWhereIsLabel: UILabel!
	@IBOutlet weak var runWhenIsLabel: UILabel!
	@IBOutlet weak var backgroundView: UIImageView!
	@IBOutlet weak var flipbookButton: UIButton!
	@IBOutlet weak var editButton: UIButton!

	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		let backBarButtonItem = UIBarButtonItem(title: self.run.whereIs, style: .plain, target: nil, action: nil)
		self.navigationItem.backBarButtonItem = backBarButtonItem
		
		self.backgroundView.image = (appDelegate as! AppDelegate).interfaceManager.blurredBackgroundImage
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()

		//    self.edgesForExtendedLayout = UIExtendedEdgeNone;
		self.edgesForExtendedLayout = UIRectEdge()
		
		self.runWhereIsLabel.text = self.run.whereIs
		self.runWhenIsLabel.text = DateFormatter.localizedString(from: self.run.whenIs, dateStyle: .short, timeStyle: .short)
	}
	
	
	@IBAction func showFlipboard(_ sender: Any) {
		let vc = FlipbookViewController(nibName: nil, bundle: nil)
		vc.run = self.run
		self.navigationController?.show(vc, sender: nil)
	}
	
	@IBAction func editPhotos(_ sender: Any) {
		let vc = PhotoEditorViewController()
		vc.run = self.run
		self.navigationController?.show(vc, sender: nil)
	}

}
