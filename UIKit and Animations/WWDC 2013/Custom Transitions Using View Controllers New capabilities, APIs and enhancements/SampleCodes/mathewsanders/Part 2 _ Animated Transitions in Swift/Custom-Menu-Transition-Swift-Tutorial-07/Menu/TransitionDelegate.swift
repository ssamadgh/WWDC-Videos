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
		
		
		// setup 2D transitions for animations
		let offstageLeft = CGAffineTransform(translationX: -150, y: 0)
		let offstageRight = CGAffineTransform(translationX: 150, y: 0)
		
		// prepare the menu
		if (self.presenting){
			
			// prepare menu to fade in
			menuView.alpha = 0
			
			// prepare menu items to slide in
			self.offStageMenuController(menuViewController) // offstage items: slide out

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
			
			if (self.presenting){
				self.onStageMenuController(menuViewController) // onstage items: slide in
			}
			else {
				self.offStageMenuController(menuViewController) // offstage items: slide out
			}
			
		}, completion: { finished in
			
			// tell our transitionContext object that we've finished animating
			transitionContext.completeTransition(true)
			
			if !self.presenting {
				UIApplication.shared.keyWindow?.addSubview(screens.to.view)
			}
		})
		
	}
	
	func offStageMenuController(_ menuViewController: MenuViewController){
		menuViewController.view.alpha = 0
		
		// setup parameters for 2D transitions for animations
		let topRowOffset  :CGFloat = 300
		let middleRowOffset :CGFloat = 150
		let bottomRowOffset  :CGFloat = 50
		
		menuViewController.textPostIcon.transform = self.offStage(-topRowOffset)
		menuViewController.textPostLabel.transform = self.offStage(-topRowOffset)
		
		menuViewController.quotePostIcon.transform = self.offStage(-middleRowOffset)
		menuViewController.quotePostLabel.transform = self.offStage(-middleRowOffset)
		
		menuViewController.chatPostIcon.transform = self.offStage(-bottomRowOffset)
		menuViewController.chatPostLabel.transform = self.offStage(-bottomRowOffset)

		menuViewController.photoPostIcon.transform = self.offStage(topRowOffset)
		menuViewController.photoPostLabel.transform = self.offStage(topRowOffset)
		
		menuViewController.linkPostIcon.transform = self.offStage(middleRowOffset)
		menuViewController.linkPostLabel.transform = self.offStage(middleRowOffset)
		
		menuViewController.audioPostIcon.transform = self.offStage(bottomRowOffset)
		menuViewController.audioPostLabel.transform = self.offStage(bottomRowOffset)
	}
	
	func onStageMenuController(_ menuViewController: MenuViewController){
		// prepare menu to fade in
		menuViewController.view.alpha = 1
		
		menuViewController.textPostIcon.transform = CGAffineTransform.identity
		menuViewController.textPostLabel.transform = CGAffineTransform.identity
		menuViewController.photoPostIcon.transform = CGAffineTransform.identity
		menuViewController.photoPostLabel.transform = CGAffineTransform.identity
		menuViewController.audioPostIcon.transform = CGAffineTransform.identity
		menuViewController.audioPostLabel.transform = CGAffineTransform.identity
		menuViewController.quotePostIcon.transform = CGAffineTransform.identity
		menuViewController.quotePostLabel.transform = CGAffineTransform.identity
		menuViewController.linkPostIcon.transform = CGAffineTransform.identity
		menuViewController.linkPostLabel.transform = CGAffineTransform.identity
		menuViewController.chatPostIcon.transform = CGAffineTransform.identity
		menuViewController.chatPostLabel.transform = CGAffineTransform.identity
	}
	
	func offStage(_ amount: CGFloat) -> CGAffineTransform {
		return CGAffineTransform(translationX: amount, y: 0)
	}
	
	
}
