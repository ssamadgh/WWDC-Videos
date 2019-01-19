//
//  PagingBaseViewController.swift
//  PhotoScrollerSwift
//
//  Created by Seyed Samad Gholamzadeh on 10/13/1396 AP.
//  Copyright © 1396 AP Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

class PagingBaseViewController: UIViewController, PagingScrollViewDataSource, PagingScrollViewDelegate {
	
	/// page scroll view
	var pagingView: PagingScrollView!
	
	/// images for paging scroll.
	var images: [UIImage] = []
	
	/// single tap for hide / show bar
	var singleTap: UITapGestureRecognizer!
	
	
	deinit {
		print("\(type(of: self)) deinited")
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()

		self.view.backgroundColor = .black
		self.automaticallyAdjustsScrollViewInsets = false
		
		// single tap to show or hide navigation bar
		self.singleTap = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap))
		self.view.addGestureRecognizer(self.singleTap)
		
		// guide button
		let rightBarButton = UIBarButtonItem(title: "Guide", style: .plain, target: self, action: #selector(handleRightBarButtonTap))
		self.navigationItem.rightBarButtonItem = rightBarButton
		
		// paging view
		self.pagingView = PagingScrollView()
		self.pagingView.backgroundColor = .white
		self.pagingView.delegate = self
		self.pagingView.dataSource = self
		self.view.addSubview(self.pagingView)
		
		// setup auto layout
		self.setupConstraints()
		self.view.layoutIfNeeded()
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

	}

	
	/// Single tap action which hides navigationBar by default implementation
	@objc func handleSingleTap() {
		UIView.animate(withDuration: 0.2) {
			if self.navigationController != nil {
				if !self.navigationController!.navigationBar.isHidden {
					self.navigationController!.navigationBar.alpha = 0
					self.navigationController!.navigationBar.isHidden = true
				}
				else {
					self.navigationController!.navigationBar.alpha = 1
					self.navigationController!.navigationBar.isHidden = false
				}
			}

			self.updatePagingBackgroundColor()
		}
	}
		
	/// Update background color. Default is white / black.
	func updatePagingBackgroundColor() {
		if self.navigationController != nil {
			self.pagingView.backgroundColor = !self.navigationController!.navigationBar.isHidden ? .white : .black

		}
		else {
			self.pagingView.backgroundColor = .black
		}
	}

	
	//MARK: - PagingScrollViewDataSource
	
	func numberOfPages(in pagingScrollView: PagingScrollView) -> Int {
		return self.images.count
	}
	
	func pagingScrollView(_ pagingScrollView: PagingScrollView, imageForPageAtIndex pageIndex: Int) -> UIImage {
		return self.images[pageIndex]
	}
	
	//MARK: - PagingScrollViewDelegate
	
	func pagingScrollView(_ pagingScrollView: PagingScrollView, didEnableZoomingTapGesture zoomingTap: UITapGestureRecognizer, forImageScrollView imageScrollView: UIScrollView) {
		self.singleTap.require(toFail: zoomingTap) // Single tap will delay its action until double tap recognizing is failed.
	}
	
	//MARK: - Rotation
	
	override var shouldAutorotate: Bool {
		return true
	}
	
	
	override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
		self.pagingView.saveCurrentStatesForRotation()
	}
	
	
	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		self.pagingView.restoreStatesForRotation(in: size)
	}

	//MARK: - Auto layout
	
	func setupConstraints() {
		self.setupPagingViewConstraints()
	}
	
	func setupPagingViewConstraints() {
		self.pagingView.translatesAutoresizingMaskIntoConstraints = false
		
		let top = NSLayoutConstraint(item: self.pagingView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1.0, constant: 0.0)
		let left = NSLayoutConstraint(item: self.pagingView, attribute: .left, relatedBy: .equal, toItem: self.view, attribute: .left, multiplier: 1.0, constant: 0.0)

		let bottom = NSLayoutConstraint(item: self.pagingView, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1.0, constant: 0.0)
		let right = NSLayoutConstraint(item: self.pagingView, attribute: .right, relatedBy: .equal, toItem: self.view, attribute: .right, multiplier: 1.0, constant: 0.0)
		
		self.view.addConstraints([top, left, bottom, right])
	}
	
	//MARK: - Target / Action
	
	@objc func handleRightBarButtonTap() {
		self.showAlertWith(title: "Guide", message: "You can swipe between pages, single tap to hide/show navigation bar, double tap or pinch to zoom image, and rotate device if you like.")
	}
	
	//MARK: - Alert
	
	/// Show simple alert view.
	func showAlertWith(title: String, message: String, dismissed: (() -> ())? = nil) {
		
		let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
		let cancel = UIAlertAction(title: "OK", style: .cancel) { (action) in
			alert.dismiss(animated: true, completion: nil)
			dismissed?()
		}
		alert.addAction(cancel)
		self.present(alert, animated: true, completion: nil)
	}
	
}
