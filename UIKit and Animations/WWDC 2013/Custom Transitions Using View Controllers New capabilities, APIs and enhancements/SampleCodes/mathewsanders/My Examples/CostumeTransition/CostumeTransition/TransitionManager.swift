//
//  TransitionManager.swift
//  CostumeTransition
//
//  Created by Seyed Samad Gholamzadeh on 11/7/1394 AP.
//  Copyright © 1394 AP Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

class TransitionManager: NSObject, UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate {
	
	private var presenting = false
	
	func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
		
		// get reference to our fromView, toView and the container view that we should perform the transition in
		let container = transitionContext.containerView
		
		let screens : (from:UIViewController, to:UIViewController) = (transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!, transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!)
		
		// assign references to our menu view controller and the 'bottom' view controller from the tuple
		// remember that our menuViewController will alternate between the from and to view controller depending if we're presenting or dismissing
		let viewController2 = !self.presenting ? screens.from as! ViewController2 : screens.to as! ViewController2
		let bottomViewController = !self.presenting ? screens.to as UIViewController : screens.from as UIViewController
		
		let menuView = viewController2.view
		let bottomView = bottomViewController.view
		
		// setup 2D transitions for animations
		let offstageLeft = CGAffineTransform(translationX: -150, y: 0)
		let offstageRight = CGAffineTransform(translationX: 150, y: 0)
		
		// prepare the menu
		if (self.presenting){
			
			// prepare menu to fade in
			menuView?.alpha = 0
			
			// prepare menu items to slide in
			viewController2.appleButton.transform = offstageRight
			viewController2.microsoftButton.transform = offstageLeft
			
		}
		
		// add the both views to our view controller
		container.addSubview(bottomView!)
		container.addSubview(menuView!)
		
		//        container?.insertSubview(screens.to.view, belowSubview: screens.from.view)
		
		let duration = self.transitionDuration(using: transitionContext)
		
		// perform the animation!
		UIView.animate(withDuration: duration, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.8, options: UIViewAnimationOptions.allowAnimatedContent, animations: {
			
			// either fade in or fade out
			if (self.presenting){
				// fade in
				menuView?.alpha = 1
				
				// onstage items: slide in
				viewController2.appleButton.transform = CGAffineTransform.identity
				viewController2.microsoftButton.transform = CGAffineTransform.identity
				
				
			} else {
				// fade out
				menuView?.alpha = 0
				
				// offstage items: slide out
				viewController2.appleButton.transform = offstageRight
				viewController2.microsoftButton.transform = offstageLeft
				
			}
			
		}, completion: { finished in
			
			// tell our transitionContext object that we've finished animating
			
			transitionContext.completeTransition(true)
			UIApplication.shared.keyWindow!.addSubview(screens.to.view)
			
			// bug: we have to manually add our 'to view' back http://openradar.appspot.com/radar?id=5320103646199808
			//                UIApplication.sharedApplication().keyWindow!.addSubview(screens.to.view)
			
		})
		
	}
	
	func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
		
		return 0.5
	}
	
	func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		self.presenting = true
		return self
	}
	
	func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		self.presenting = false
		return self
	}
	
}
