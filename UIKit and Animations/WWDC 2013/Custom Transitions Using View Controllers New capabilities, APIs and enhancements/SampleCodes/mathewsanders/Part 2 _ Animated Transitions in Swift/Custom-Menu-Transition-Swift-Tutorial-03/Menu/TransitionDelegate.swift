//
//  TransitionDelegate.swift
//  CustomTransition
//
//  Created by Seyed Samad Gholamzadeh on 6/16/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit


class TransitionDelegate: NSObject, UIViewControllerTransitioningDelegate {
	
	
	func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		return TransitionAnimation(presenting: true)
	}
	
	func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		return TransitionAnimation(presenting: false)
	}
	
}


class TransitionAnimation: NSObject, UIViewControllerAnimatedTransitioning {
	
	private var presenting: Bool
	
	init(presenting: Bool) {
		self.presenting = presenting
	}
	
	func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
		return 1.0
	}
	
	func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
		
		// Get the two view controllers
		
		// create a tuple of our screens
		let screens : (from:UIViewController, to:UIViewController) = (transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!, transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!)
		
		// assign references to our menu view controller and the 'bottom' view controller from the tuple
		// remember that our menuViewController will alternate between the from and to view controller depending if we're presenting or dismissing
		let menuViewController = !self.presenting ? screens.from as! MenuViewController : screens.to as! MenuViewController
		let bottomViewController = !self.presenting ? screens.to as UIViewController : screens.from as UIViewController

		let menuView = menuViewController.view!
		let bottomView = bottomViewController.view!
		
		// get reference to our fromView, toView and the container view that we should perform the transition in
		let container = transitionContext.containerView
		
		
		// add the both views to our view controller
		
		container.addSubview(bottomView)
		container.addSubview(menuView)
		if presenting {
			menuView.alpha = 0
		}

		// get the duration of the animation
		// DON'T just type '0.5s' -- the reason why won't make sense until the next post
		// but for now it's important to just follow this approach
		let duration = self.transitionDuration(using: transitionContext)
		
		// perform the animation!
		// for this example, just slid both fromView and toView to the left at the same time
		// meaning fromView is pushed off the screen and toView slides into view
		// we also use the block animation usingSpringWithDamping for a little bounce
		UIView.animate(withDuration: duration, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.8, options: .allowAnimatedContent, animations: {
			
			menuView.alpha = self.presenting ? 1 : 0

			
		}, completion: { finished in
			
			// tell our transitionContext object that we've finished animating
			transitionContext.completeTransition(true)
			
			if !self.presenting {
				UIApplication.shared.keyWindow?.addSubview(screens.to.view)
			}
		})
		
	}
	
	
}
