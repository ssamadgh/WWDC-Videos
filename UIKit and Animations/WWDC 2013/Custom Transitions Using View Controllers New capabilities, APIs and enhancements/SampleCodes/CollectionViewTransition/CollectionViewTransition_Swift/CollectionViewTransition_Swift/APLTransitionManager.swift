//
//  APLTransitionManager.swift
//  CollectionViewTransition_Swift
//
//  Created by Seyed Samad Gholamzadeh on 7/1/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.

//  Abstract: Responsible for managing the transition between the two collection views via the pinch gesture recognizer.

import UIKit

protocol APLTransitionManagerDelegate: class {
	func interactionBegan(at point: CGPoint)
}

class APLTransitionManager: NSObject, UIViewControllerAnimatedTransitioning, UIViewControllerInteractiveTransitioning {

	var delegate: APLTransitionManagerDelegate!
	var hasActiveInteraction: Bool! = false
	var navigationOperation: UINavigationControllerOperation!
	var collectionView: UICollectionView!
	var transitionLayout: APLTransitionLayout!
	var context: UIViewControllerContextTransitioning!
	var initialPinchDistance: CGFloat!
	var initialPinchPoint: CGPoint!
	
	init(collectionView: UICollectionView) {
		super.init()
		
		// setup our pinch gesture:
		//  pinch in closes photos down into a stack,
		//  pinch out expands the photos intoa  grid
		//
		let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
		collectionView.addGestureRecognizer(pinchGesture)
		self.collectionView = collectionView
	}
	
	func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
		
	}
	
	func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
		// transition animation time between grid and stack layout
		return 1.0
	}
	
	// required method for view controller transitions, called when the system needs to set up
	// the interactive portions of a view controller transition and start the animations
	//
	func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
		self.context = transitionContext
		let fromCollectionViewController = transitionContext.viewController(forKey: .from) as! UICollectionViewController
		let toCollectionViewController = transitionContext.viewController(forKey: .to) as! UICollectionViewController

		let containerView = transitionContext.containerView
		containerView.addSubview(toCollectionViewController.view)
//		containerView.insertSubview(toCollectionViewController.view, at: 0)
		self.transitionLayout = fromCollectionViewController.collectionView!.startInteractiveTransition(to: toCollectionViewController.collectionViewLayout, completion: { (didFinish, didComplete) in
			self.context.completeTransition(didComplete)
			self.transitionLayout = nil
			self.context = nil
			self.hasActiveInteraction = false
		}) as? APLTransitionLayout
	}
	
	func updateWithProgress(_ progress: CGFloat, andOffset offset: UIOffset) {
		
		 // we must have a valid context for updates
		if self.context != nil && progress != self.transitionLayout!.transitionProgress || offset == self.transitionLayout.offset {
			self.transitionLayout.offset = offset
			self.transitionLayout.transitionProgress = progress
			self.transitionLayout.invalidateLayout()
			self.context.updateInteractiveTransition(progress)
		}
	}
	
	// called by our pinch gesture recognizer when the gesture has finished or cancelled, which
	// in turn is responsible for finishing or cancelling the transition.
	//
	func endInteractionWith(success: Bool) {
		
		if context == nil {
			self.hasActiveInteraction = false
		}
		// allow for the transition to finish when it's progress has started as a threshold of 10%,
		// if you want to require the pinch gesture with a wider threshold, change it it a value closer to 1.0
		//
		else if self.transitionLayout!.transitionProgress > 0.1 && success {
			self.collectionView.finishInteractiveTransition()
			self.context.finishInteractiveTransition()
		}
		else {
			self.collectionView.cancelInteractiveTransition()
			self.context.cancelInteractiveTransition()
		}
	}
	
	// action method for our pinch gesture recognizer
	//
	@objc func handlePinch(_ sender: UIPinchGestureRecognizer) {
		// here we want to end the transition interaction if the user stops or finishes the pinch gesture
		if sender.state == .ended {
			self.endInteractionWith(success: true)
		}
		else if sender.state == .cancelled {
			self.endInteractionWith(success: false)
		}
		else if sender.numberOfTouches == 2 {
			// here we expect two finger touch
			var point: CGPoint!      // the main touch point
			var point1: CGPoint!     // location of touch #1
			var point2: CGPoint!     // location of touch #2
			var distance: CGFloat!   // computed distance between both touches

			// return the locations of each gesture’s touches in the local coordinate system of a given view
			point1 = sender.location(ofTouch: 0, in: sender.view)
			point2 = sender.location(ofTouch: 1, in: sender.view)
			
			distance = sqrt(pow((point1.x - point2.x), 2.0) + pow((point1.y - point2.y), 2.0))
			
			// get the main touch point
			point = sender.location(in: sender.view)
			
			if sender.state == .began {
				// start the pinch in our out
				if !self.hasActiveInteraction {
					self.initialPinchDistance = distance
					self.initialPinchPoint = point
					self.hasActiveInteraction = true    // the transition is in active motion
					self.delegate.interactionBegan(at: point)
				}
			}
			
			if self.hasActiveInteraction {
				
				if sender.state == .changed {
					// update the progress of the transtition as the user continues to pinch
					let offsetX: CGFloat = point.x - self.initialPinchPoint.x
					let offsetY: CGFloat = point.y - self.initialPinchPoint.y
					let offsetToUse = UIOffset(horizontal: offsetX, vertical: offsetY)
					
					var distanceDelta: CGFloat = distance - self.initialPinchDistance
					if self.navigationOperation == UINavigationControllerOperation.pop {
						distanceDelta  = -distanceDelta
					}
					let dimension = sqrt(self.collectionView.bounds.size.width * self.collectionView.bounds.size.width + self.collectionView.bounds.size.height * self.collectionView.bounds.size.height)
					let progress: CGFloat = max(min(distanceDelta/dimension, 1.0), 0.0)

					// tell our UICollectionViewTransitionLayout subclass (transitionLayout)
					// the progress state of the pinch gesture
					//
					self.updateWithProgress(progress, andOffset: offsetToUse)
				}
			}
		}
	}
	
}
