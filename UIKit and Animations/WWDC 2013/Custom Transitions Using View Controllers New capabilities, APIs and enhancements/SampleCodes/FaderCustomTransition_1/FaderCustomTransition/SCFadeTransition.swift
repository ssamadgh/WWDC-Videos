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
		
		// Add the two VC views to the container. Hide the to
		if presenting {
			containerView.addSubview(toVC.view)
		}

		if presenting {
			toVC.view.alpha = 0
		}
		
		// Perform the animation
		UIView.animate(withDuration: self.transitionDuration(using: transitionContext), delay: 0, options: UIViewAnimationOptions.allowAnimatedContent, animations: {

			if self.presenting {
				toVC.view.alpha = 0.5
			}
			else {
				fromVC.view.alpha = 0
			}

		}) { (finished) in
						
			// And then we need to tell the context that we're done
			transitionContext.completeTransition(true)
			
		}

	}
	
	
	
	
}
