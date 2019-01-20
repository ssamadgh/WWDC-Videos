//
//  ViewController.swift
//  PresentationController
//
//  Created by Seyed Samad Gholamzadeh on 10/18/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

class TransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {

	deinit {
		print("TransitioningDelegate deinited")
	}
	
	var animationController: OverlayAnimatedTransitioning {
		let animationController = OverlayAnimatedTransitioning()
		return animationController
	}

	func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
		return PresentationController(presentedViewController: presented, presenting: presenting)
	}
	
	func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		let animationController = self.animationController
		animationController.isPresentation = true
		return animationController
	}
	
	func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		let animationController = self.animationController
		animationController.isPresentation = false
		return animationController
	}

}


class OverlayAnimatedTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
	
	deinit {
		print("OverlayAnimatedTransitioning deinited")
	}

	var isPresentation: Bool!
	
	func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
		return 0.5
	}
	
	func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
		
		let fromVC = transitionContext.viewController(forKey: .from)
		let toVC = transitionContext.viewController(forKey: .to)
		
		let fromView = fromVC?.view
		let toView = toVC?.view
		
		let containerView = transitionContext.containerView
		
		let isPresentation = self.isPresentation!
		
		if isPresentation {
			containerView.addSubview(toView!)
		}
		
		let animatingVC = isPresentation ? toVC : fromVC
		let animatingView = animatingVC?.view
		
		let appearedFrame = transitionContext.finalFrame(for: animatingVC!)
		var dismissedFrame = appearedFrame
		dismissedFrame.origin.x += dismissedFrame.size.width
		
		let initialFrame = isPresentation ? dismissedFrame : appearedFrame;
		let finalFrame = isPresentation ? appearedFrame : dismissedFrame;
		
		animatingView?.frame = initialFrame
		
		UIView.animate(withDuration: self.transitionDuration(using: transitionContext), delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 10.0, options: [.allowUserInteraction, .beginFromCurrentState], animations: {
			animatingView?.frame = finalFrame
		}) { (finished) in
			
			if !self.isPresentation {
				fromView?.removeFromSuperview()
			}
			
			transitionContext.completeTransition(true)
		}
	}
	
}

