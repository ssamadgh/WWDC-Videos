//
//  SCNavControllerDelegate.swift
//  FaderCustomTransition
//
//  Created by Seyed Samad Gholamzadeh on 6/16/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit


class SCNavControllerDelegate: NSObject, UINavigationControllerDelegate {
	
	func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		return SCFadeTransition(presenting: true)
	}
	
}
