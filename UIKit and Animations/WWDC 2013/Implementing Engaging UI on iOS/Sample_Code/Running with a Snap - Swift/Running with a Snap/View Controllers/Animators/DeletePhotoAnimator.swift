//
//  DeletePhotoAnimator.swift
//  Running with a Snap - Swift
//
//  Created by Seyed Samad Gholamzadeh on 7/13/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

let sectionSize: CGFloat = 20.0

class DeletePhotoAnimator: NSObject, UIViewControllerAnimatedTransitioning {

	var animator: UIDynamicAnimator!
	var gravity: UIGravityBehavior!
	var collision: UICollisionBehavior!
	var propertyBehavior: UIDynamicItemBehavior!
	var scanlineImageView: UIImageView!
	
	func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
		return 2.0
	}
	
	func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
		let fromVC = transitionContext.viewController(forKey: .from) as! EditPhotoViewController
		let toVC = transitionContext.viewController(forKey: .to)!

		let toView = toVC.view!
		let fromView = fromVC.view!
		
		// Stick the toView into position
		toView.frame = transitionContext.finalFrame(for: toVC)
		transitionContext.containerView.insertSubview(toView, belowSubview: fromView)
		
		let numberOfRows = ceil(fromVC.imageView.frame.height/sectionSize)
		let perRowAnimationDelay = CGFloat(self.transitionDuration(using: transitionContext))/numberOfRows
		var accumulatedRowAnimationDelay: TimeInterval = 0.08
		
		// Use a holder view so that placement is a bit easier on us later
		let holderView = UIView(frame: fromVC.imageView.frame)
		transitionContext.containerView.addSubview(holderView)
		self.animator = UIDynamicAnimator(referenceView: holderView)
		self.gravity = UIGravityBehavior()
		self.animator.addBehavior(self.gravity)
		self.propertyBehavior = UIDynamicItemBehavior()
		self.propertyBehavior.density = 50.0
		self.animator.addBehavior(self.propertyBehavior)
		
		var thisRowsViews: [SubsnapshotContainerView] = []
		
		var snapshot: UIView!
		
		// In seed 2, the method -[UIView snapshot] has changed to -[UIView snapshotView]. Please use -snapshotView in seed 2 and going forward.
		//    snapshot = [fromVC.imageView snapshot];
		snapshot = fromVC.imageView.snapshotView(afterScreenUpdates: false)
		
		var y: CGFloat = fromVC.imageView.frame.height - sectionSize
		
		while y >= 0 {
			thisRowsViews.removeAll()
			
			var x: CGFloat = 0
			
			while x < fromVC.imageView.frame.width {
				let subrect = CGRect(x: x, y: y, width: sectionSize, height: sectionSize)
				let containerView = SubsnapshotContainerView(frame: subrect)
				
				var subsnapshot: UIView!
				// In seed 2, the method -[UIView resizableSnapshotFromRect:withCapInsets:] has changed to -[UIView resizableSnapshotViewFromRect:withCapInsets:]. Please use -resizableSnapshotViewFromRect:withCapInsets: in seed 2 and going forward.
				//            subsnapshot = [snapshot resizableSnapshotFromRect:subrect withCapInsets:UIEdgeInsetsZero];
				subsnapshot = snapshot.resizableSnapshotView(from: subrect, afterScreenUpdates: false, withCapInsets: .zero)
				containerView.insertSubview(snapshot, belowSubview: containerView.coverView)
				containerView.layer.borderWidth = 1.0 / UIScreen.main.scale
				containerView.layer.borderColor = UIColor.black.cgColor
				
				holderView.addSubview(containerView)
				holderView.sendSubview(toBack: containerView)
				thisRowsViews.append(containerView)
				
				x += sectionSize
			}
			
			
			// Need to make a copy of the mutable array otherwise the animation block will only ever see the last row's views.
			let views = thisRowsViews
			Timer.scheduledTimer(timeInterval: accumulatedRowAnimationDelay, target: self, selector: #selector(addItemsToEngine(_:)), userInfo: views, repeats: false)
			
			
			// Turns each square white, then makes each disappear
			UIView.animate(withDuration: 0.05, delay: accumulatedRowAnimationDelay, options: .curveLinear, animations: {
				
				for containerView in views {
					containerView.coverView.alpha = 1.0
				}
				
			}) { (finished) in
				
				UIView.animate(withDuration: 0.4, delay: 0.1, options: .curveLinear, animations: {
					for containerView in views {
						containerView.alpha = 0.0
					}
				}) { (finished) in
					for containerView in views {
						self.gravity.removeItem(containerView)
						self.propertyBehavior.removeItem(containerView)
						self.animator.removeBehavior(containerView.push)
						containerView.removeFromSuperview()
					}
				}
				
			}
			
			accumulatedRowAnimationDelay += Double(perRowAnimationDelay)
			y -= sectionSize
		}
		
		var scanline = UIImage(named: "scanline")?.resizableImage(withCapInsets: .zero, resizingMode: .tile)
		scanline = scanline?.withRenderingMode(.alwaysTemplate)
		self.scanlineImageView = UIImageView(frame: CGRect(x: 0, y: holderView.frame.maxY + 5, width: transitionContext.containerView.frame.width, height: 20))
		self.scanlineImageView.image = scanline
		transitionContext.containerView.addSubview(self.scanlineImageView)
		
		UIView.animate(withDuration: 0.05, delay: accumulatedRowAnimationDelay, options: .curveLinear, animations: {
			var r = self.scanlineImageView.frame
			r.origin.y = holderView.frame.minY - 5
			self.scanlineImageView.frame = r
			
		}) { (finished) in
			
			UIView.animate(withDuration: 0.30, animations: {
				self.scanlineImageView.alpha = 0.0
				fromVC.view.alpha = 0.0
				
			})  { (finished) in
				self.animator.removeAllBehaviors()
				
				// Important! Call this method when all of our animations are finished
				transitionContext.completeTransition(true)
				UIApplication.shared.keyWindow!.addSubview(toVC.view)

			}
		}
		
		
		// Now that all the animations are setup, hide the image we're going to delete so it doesn't show up while we're deleting.
		fromVC.imageView.isHidden = true
	}
	
	@objc func addItemsToEngine(_ aTimer: Timer) {
		let views = aTimer.userInfo! as! [UIView]
		
		for view in views {
			let containerView = view as! SubsnapshotContainerView
			self.gravity.addItem(containerView)
			self.propertyBehavior.addItem(containerView)
			
			// Upwards shove
			let push = UIPushBehavior(items: [containerView], mode: .instantaneous)
			push.setAngle(randomFloat(4.4, 5.1), magnitude: 5.0)
			self.animator.addBehavior(push)
			
			containerView.push = push
		}
	}
	
}

class SubsnapshotContainerView: UIView {
	var coverView: UIView!
	var push: UIPushBehavior!
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		self.coverView = UIView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height))
		self.coverView.backgroundColor = UIColor(white: 1.0, alpha: 0.8)
		self.coverView.alpha = 0.0
		self.addSubview(self.coverView)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
