//
//  FlipbookViewController.swift
//  Running with a Snap - Swift
//
//  Created by Seyed Samad Gholamzadeh on 7/14/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

class FlipbookViewController: UIViewController, UICollisionBehaviorDelegate {

	var run: Run!

	var displayedPhotoIndex: Int = 0
	
	@IBOutlet weak var contentView: UIView!
	@IBOutlet weak var lightpoolView: UIImageView!
	var animator: UIDynamicAnimator!
	var gravity: UIGravityBehavior!
	var collision: UICollisionBehavior!
	var springyBehavior: UIDynamicItemBehavior!
	var attachment: UIAttachmentBehavior!
	var link: CADisplayLink!
	var fixedBounceItem: UIImageView!
	var spotlightView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

		let tap = UITapGestureRecognizer(target: self, action: #selector(tappedView(_:)))
		self.view.addGestureRecognizer(tap)
		
		let pan = UIPanGestureRecognizer(target: self, action: #selector(pannedView(_:)))
		self.view.addGestureRecognizer(pan)
		
		self.lightpoolView.alpha = 0.20
		
		self.animator = UIDynamicAnimator(referenceView: self.contentView)
		self.gravity = UIGravityBehavior()
		let vector = CGVector(dx: 0, dy: 3.0)
		self.gravity.gravityDirection = vector
		
		self.collision = UICollisionBehavior()
		self.collision.collisionDelegate = self
		collision.collisionMode = .boundaries
//		let midY: CGFloat = self.lightpoolView.center.y
		let midY: CGFloat = 400

		self.collision.addBoundary(withIdentifier: "lightpool-boundary" as NSCopying, from: CGPoint(x: 100, y: midY), to: CGPoint(x: self.contentView.bounds.maxX, y: midY))
		
		self.springyBehavior = UIDynamicItemBehavior()
		self.springyBehavior.elasticity = 1.0
		self.animator.addBehavior(self.springyBehavior)
		
		self.animator.addBehavior(self.gravity)
		self.animator.addBehavior(self.collision)
    }
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		self.link?.invalidate()
	}
	
	func nextPhoto() {
		// Loop through photos forever
		if displayedPhotoIndex >= self.run.numberOfPhotos { displayedPhotoIndex = 0 }
		let image = self.run.photo(at: self.displayedPhotoIndex, of: .preview)
		assert(image != nil, "Did not load image from run!")
		self.displayedPhotoIndex += 1
		
		let startingRect: CGRect = CGRect(x: self.contentView.bounds.maxX - image!.size.width, y: image!.size.height / 2, width: image!.size.width * image!.scale, height: image!.size.height * image!.scale)
		let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: startingRect.width, height: startingRect.height))
		imageView.isUserInteractionEnabled = false
		imageView.contentMode = .scaleAspectFit
		imageView.image = image

		let containerView = FlipbookContainerView(frame: startingRect, imageView: imageView)
		containerView.isUserInteractionEnabled = false
		
		if self.fixedBounceItem != nil {
			self.contentView.insertSubview(containerView, belowSubview: self.fixedBounceItem)
		}
		else {
			self.contentView.addSubview(containerView)
		}

		UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveLinear, animations: {
			containerView.alpha = 1.0
			containerView.imageView.transform = .identity
		}, completion: nil)
		
		let sidePush = UIPushBehavior(items: [containerView], mode: .instantaneous)
		sidePush.setAngle(CGFloat.pi, magnitude: 29.0)
		self.animator.addBehavior(sidePush)
		
		containerView.initialPush = sidePush
		
//		if self.fixedBounceItem != nil {
//			self.contentView.insertSubview(containerView, belowSubview: self.fixedBounceItem)
//		}
//		else {
//			self.contentView.addSubview(containerView)
//		}
		
		self.collision.addItem(containerView)
		self.gravity.addItem(containerView)
		self.springyBehavior.addItem(containerView)
	}
	
	@objc func linkFired(_ link: CADisplayLink) {
		self.nextPhoto()
	}
	
	@objc func tappedView(_ tapGesture: UITapGestureRecognizer) {
		if self.link != nil {
			self.navigationController?.setNavigationBarHidden(false, animated: true)
			
			UIView.animate(withDuration: 0.25) {
				var r = self.spotlightView.frame
				r.origin = CGPoint(x: 0, y: -r.height)
				self.spotlightView.frame = r
				self.lightpoolView.alpha = 0.20
			}
			
			self.link.invalidate()
			self.link = nil
		}
		else {
			self.navigationController?.setNavigationBarHidden(true, animated: true)
			
			if self.spotlightView == nil {
				let spotlight = UIImage(named: "spotlight")!
				self.spotlightView = UIImageView(image: spotlight)
				self.spotlightView.isUserInteractionEnabled = false
				self.spotlightView.alpha = 0.50
				var r = self.spotlightView.frame
				r.origin = CGPoint(x: 0, y: -spotlight.size.height)
				self.spotlightView.frame = r
				
				self.view.addSubview(self.spotlightView)
			}
			
			UIView.animate(withDuration: 0.25) {
				var r = self.spotlightView.frame
				r.origin = CGPoint(x: 0, y: 0)
				self.spotlightView.frame = r
				self.lightpoolView.alpha = 0.80;
			}
			
			self.link = CADisplayLink(target: self, selector: #selector(linkFired(_:)))
			self.link.preferredFramesPerSecond = 8
			self.link.add(to: RunLoop.current, forMode: RunLoopMode.commonModes)
		}
	}
	
	@objc func pannedView(_ panGesture: UIPanGestureRecognizer) {
//		guard self.fixedBounceItem.convert(fixedBounceItem.bounds, to: nil).contains(panGesture.location(in: nil)) else {
//			return
//		}
		if panGesture.state == .began, self.fixedBounceItem.convert(fixedBounceItem.bounds, to: nil).contains(panGesture.location(in: nil))  {
			let bounceItemViewPoint = self.fixedBounceItem.convert(panGesture.location(in: nil), from: nil)
			let attachPoint = CGPoint(x: bounceItemViewPoint.x <= self.fixedBounceItem.bounds.midX ? -5 : 5, y: -self.fixedBounceItem.bounds.midY)
			
			// We must container the snapshot because we want to apply a transform to it. UIKit Dynamics also sets transforms and will stomp our transform if we don't isolate the snapshot.
			let container = UIView(frame: self.fixedBounceItem.frame)
			
			var snapshot: UIView!
			// In seed 2, the method -[UIView snapshot] has changed to -[UIView snapshotView]. Please use -snapshotView in seed 2 and going forward.
			//        snapshot = [_fixedBounceItem snapshot];
			snapshot = self.fixedBounceItem.snapshotView(afterScreenUpdates: false)
			
			container.addSubview(snapshot)
			self.contentView.addSubview(container)
			self.contentView.bringSubview(toFront: container)
			UIView.animate(withDuration: 0.4) {
				snapshot.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
			}
			
			self.gravity.addItem(container)
			
			self.attachment = UIAttachmentBehavior(item: container, attachedToAnchor: self.view.convert(panGesture.location(in: nil), from: nil))
			
			let offscreenBehavior = UIDynamicItemBehavior(items: [container])
			offscreenBehavior.action = {
				if let window = container.window, !window.bounds.intersects(container.frame) {
					self.gravity.removeItem(container)
					self.animator.removeBehavior(offscreenBehavior)
					container.removeFromSuperview()
				}
			}
			self.animator.addBehavior(self.attachment)
			self.animator.addBehavior(offscreenBehavior)
			
		}
		else if panGesture.state == .changed {
			self.attachment.anchorPoint = self.view.convert(panGesture.location(in: nil), from: nil)
		}
		else if panGesture.state == .ended {
			self.animator.removeBehavior(self.attachment)
			self.attachment = nil
		}
	}
	
	func collisionBehavior(_ behavior: UICollisionBehavior, endedContactFor item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying?) {
		if self.fixedBounceItem == nil {
			self.fixedBounceItem = UIImageView(frame: (item as! UIView).frame)
			self.fixedBounceItem.isUserInteractionEnabled = false
			self.contentView.addSubview(self.fixedBounceItem)
			self.contentView.bringSubview(toFront: self.fixedBounceItem)
		}
		
		self.fixedBounceItem.image = (item as! FlipbookContainerView).imageView.image
		
		UIView.animate(withDuration: 0.75, delay: 0.0, options: .curveLinear, animations: {
			(item as! UIView).alpha = 0.0
			(item as! FlipbookContainerView).imageView.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
		}) { (finished) in
			self.collision.removeItem(item)
			self.gravity.removeItem(item)
			self.springyBehavior.removeItem(item)
			self.animator.removeBehavior((item as! FlipbookContainerView).initialPush)
			(item as! UIView).removeFromSuperview()
		}

	}

}

class FlipbookContainerView: UIView {
	
	var initialPush: UIPushBehavior!
	var imageView: UIImageView!

	init(frame: CGRect, imageView: UIImageView) {
		super.init(frame: frame)
		
		self.imageView = imageView
		self.addSubview(self.imageView)
		self.imageView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
		self.alpha = 0.0
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
