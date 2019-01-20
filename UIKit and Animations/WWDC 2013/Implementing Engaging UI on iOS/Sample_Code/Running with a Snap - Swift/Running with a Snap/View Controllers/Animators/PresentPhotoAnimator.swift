//
//  PresentPhotoAnimator.swift
//  Running with a Snap - Swift
//
//  Created by Seyed Samad Gholamzadeh on 7/13/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

class PresentPhotoAnimator: NSObject, UIViewControllerAnimatedTransitioning {

	let animationTime: Double = 0.25
	var isPresenting: Bool = false
	
	func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
		return animationTime
	}
	
	// A very basic view controller presentation. It's the same as the default modal presentation style except that when presenting, we keep the fromView visible on-screen.
	func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
		let fromVC = transitionContext.viewController(forKey: .from)!
		let toVC = transitionContext.viewController(forKey: .to)!
		
		var endFrame = transitionContext.initialFrame(for: fromVC)
		
		if self.isPresenting {
			fromVC.view.frame = endFrame
			
			let fromView = fromVC.view!
			let toView = toVC.view!

			transitionContext.containerView.addSubview(fromView)
			transitionContext.containerView.addSubview(toView)
			
			var startFrame = endFrame
			startFrame.origin.y += endFrame.height
			 toView.frame = startFrame
			
			UIView.animate(withDuration: self.transitionDuration(using: transitionContext), delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.5, options: UIViewAnimationOptions(), animations: {
				toView.frame = endFrame
			}) { (finished) in
				transitionContext.completeTransition(true)
			}
		}
		else {
			let toView = toVC.view!
			toView.frame = endFrame
			transitionContext.containerView.addSubview(toView)
			transitionContext.containerView.addSubview(fromVC.view)
			endFrame.origin.y += endFrame.height
			
			UIView.animate(withDuration: self.transitionDuration(using: transitionContext), delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.5, options: UIViewAnimationOptions(), animations: {
				fromVC.view.frame = endFrame
			}) { (finished) in
				transitionContext.completeTransition(true)
				if !self.isPresenting {
					UIApplication.shared.keyWindow!.addSubview(toVC.view)
				}
			}

		}
	}
	
}
