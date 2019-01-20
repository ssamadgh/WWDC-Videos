//
//  AAPLCoolTransitioner.swift
//  LookInside_Swift
//
//  Created by Seyed Samad Gholamzadeh on 7/18/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

class AAPLCoolTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
	
	var animationController: AAPLCoolAnimatedTransitioning {
		let animationController = AAPLCoolAnimatedTransitioning()
		return animationController
	}
	
	func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
		return AAPLCoolPresentationController(presentedViewController: presented, presenting: presenting)
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

class AAPLCoolAnimatedTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
	
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
		
		animatingView?.frame = transitionContext.finalFrame(for: animatingVC!)
		
		let presentedTransform = CGAffineTransform.identity
		let dismissedTransform = CGAffineTransform(scaleX: 0.001, y: 0.001)
		
		animatingView?.transform = isPresentation ? dismissedTransform : presentedTransform
		
		UIView.animate(withDuration: self.transitionDuration(using: transitionContext), delay: 0, usingSpringWithDamping: 300.0, initialSpringVelocity: 5.0, options: [.allowUserInteraction, .beginFromCurrentState], animations: {
			animatingView?.transform = isPresentation ? presentedTransform : dismissedTransform
		}) { (finished) in
			
			if !self.isPresentation {
				fromView?.removeFromSuperview()
			}
			
			transitionContext.completeTransition(true)
		}

	}
	
}

