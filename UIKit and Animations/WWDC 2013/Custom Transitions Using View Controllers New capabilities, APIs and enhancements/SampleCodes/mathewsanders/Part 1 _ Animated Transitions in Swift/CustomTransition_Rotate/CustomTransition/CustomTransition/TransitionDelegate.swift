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
		
		// get reference to our fromView, toView and the container view that we should perform the transition in
		let container = transitionContext.containerView
		let fromView = transitionContext.view(forKey: UITransitionContextViewKey.from)!
		let toView = transitionContext.view(forKey: UITransitionContextViewKey.to)!
		
		// set up from 2D transforms that we'll use in the animation
		let π : CGFloat = CGFloat.pi
		
		let offScreenRotateIn = CGAffineTransform(rotationAngle: -π/2)
		let offScreenRotateOut = CGAffineTransform(rotationAngle: π/2)
		
		// set the start location of toView depending if we're presenting or not
		toView.transform = self.presenting ? offScreenRotateIn : offScreenRotateOut
		
		// set the anchor point so that rotations happen from the top-left corner
		toView.layer.anchorPoint = CGPoint(x:0, y:0)
		fromView.layer.anchorPoint = CGPoint(x:0, y:0)
		
		// updating the anchor point also moves the position to we have to move the center position to the top-left to compensate
		toView.layer.position = CGPoint(x:0, y:0)
		fromView.layer.position = CGPoint(x:0, y:0)
		
		// add the both views to our view controller
		container.addSubview(toView)
		container.addSubview(fromView)
		
		// get the duration of the animation
		// DON'T just type '0.5s' -- the reason why won't make sense until the next post
		// but for now it's important to just follow this approach
		let duration = self.transitionDuration(using: transitionContext)
		
		// perform the animation!
		// for this example, just slid both fromView and toView to the left at the same time
		// meaning fromView is pushed off the screen and toView slides into view
		// we also use the block animation usingSpringWithDamping for a little bounce
		UIView.animate(withDuration: duration, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.8, options: .allowAnimatedContent, animations: {
			
			fromView.transform = self.presenting ?  offScreenRotateOut : offScreenRotateIn
			toView.transform = CGAffineTransform.identity
			
		}, completion: { finished in
			
			// tell our transitionContext object that we've finished animating
			transitionContext.completeTransition(true)
			
		})
		
	}
	
	
}
