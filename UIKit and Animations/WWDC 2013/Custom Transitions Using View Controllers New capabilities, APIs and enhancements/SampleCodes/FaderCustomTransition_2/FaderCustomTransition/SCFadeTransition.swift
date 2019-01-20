//
//  SCFadeTransition.swift
//  FaderCustomTransition
//
//  Created by Seyed Samad Gholamzadeh on 6/16/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

class SCFadeTransition: NSObject, UIViewControllerAnimatedTransitioning {
	
	private var presenting: Bool

	init(presenting: Bool) {
		self.presenting = presenting
	}
	
	func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
		return 0.75
	}
	
	func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
		guard transitionContext.isAnimated else { return }
		
		// Get the two view controllers
		guard let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from),
		let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
			else { return }

		// Get the container view - where the animation has to happen
		let containerView = transitionContext.containerView
		
		
		var toVCFinalFrame = toVC.view.frame
		let center = toVC.view.center

		// Add the two VC views to the container. Hide the to
		if presenting {
			containerView.addSubview(fromVC.view)
			containerView.addSubview(toVC.view)
			
//			toVCFinalFrame.size.width -= 100
			toVCFinalFrame.size.height -= 300

//			toVCFinalFrame.origin.x += 50
			toVCFinalFrame.origin.y += 50
			toVC.view.clipsToBounds = true
			toVC.view.frame = toVCFinalFrame
			toVC.view.frame.origin.y += toVCFinalFrame.height
			
			toVC.view.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
			toVC.view.layer.cornerRadius = 20
		}
		else {
			containerView.addSubview(toVC.view)
			containerView.addSubview(fromVC.view)
		}

		if presenting {
			toVC.view.alpha = 0
		}
		
		// Perform the animation
		UIView.animate(withDuration: self.transitionDuration(using: transitionContext), delay: 0, options: UIViewAnimationOptions.allowAnimatedContent, animations: {

			if self.presenting {
				toVC.view.alpha = 1
				toVC.view.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
				toVC.view.center = center

			}
			else {
				fromVC.view.alpha = 0
			}

		}) { (finished) in
			
			// Let's get rid of the old VC view
//			fromVC.view.removeFromSuperview()
			
			// And then we need to tell the context that we're done
			transitionContext.completeTransition(true)
			if !self.presenting {
				UIApplication.shared.keyWindow!.addSubview(toVC.view)
			}
			
		}

	}
	
	
	
	
}
