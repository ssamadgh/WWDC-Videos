//
//  VerticalPagingViewController.swift
//  PhotoScrollerSwift
//
//  Created by Seyed Samad Gholamzadeh on 10/14/1396 AP.
//  Copyright © 1396 AP Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

class VerticalPagingViewController: PagingBaseViewController {
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.pagingView.isParallaxScrollingEnabled = true
		self.pagingView._navigationOrientation = .vertical
		self.pagingView.reloadData()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		if UIDeviceOrientationIsPortrait(UIDevice.current.orientation) {
			self.showAlertWith(title: "What's now?", message: "Rotate your device to landscape, then you can see the parallax effect.")
		}
	}
	
}

