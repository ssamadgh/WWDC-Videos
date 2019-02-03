//
//  TtransformGestureRecognizre.swift
//  MultitouchDemoWithGesture-Swift
//
//  Created by Seyed Samad Gholamzadeh on 10/30/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit


//extension UITouch {
//	
//	func compareAddress(obj:AnyObject) -> ComparisonResult {
//		
//		if unsafeAddressOf(self) < unsafeAddressOf(obj) {
//			return ComparisonResult.orderedAscending
//		}
//		else if unsafeAddressOf(self) == unsafeAddressOf(obj) {
//			return ComparisonResult.orderedSame
//		}
//		else {
//			return ComparisonResult.orderedDescending
//		}
//	}
//}


class TtransformGestureRecognizre: UIGestureRecognizer {
	
	var originalTransform: CGAffineTransform!
	var touchBeginPoints: [UITouch : CGPoint] = [:]
	var incrementalTransform: CGAffineTransform!
	
	var transform: CGAffineTransform {
		get {
			return self.originalTransform.concatenating(self.incrementalTransform)
		}
		
		set {
			self.originalTransform = newValue
			incrementalTransform = .identity
		}
	}
	
	override init(target: Any?, action: Selector?) {
		super.init(target: target, action: action)
		
		originalTransform = .identity
		incrementalTransform = .identity
	}
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
		guard var currentTouches = event.touches(for: self) else { return }
		currentTouches.subtract(touches)
		if !currentTouches.isEmpty {
			self.updateOriginalTransform(for: currentTouches)
			self.cacheBeginPoint(for: currentTouches)
		}
		self.cacheBeginPoint(for: touches)
	}
	
	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
		if let touches = event.touches(for: self) {
			self.incrementalTransform = self.incrementalTransform(with: touches)
		}
		
//		if self.state == .possible {
//			if !self.incrementalTransform.isIdentity {
//				self.state = .began
//			}
//		}
//		else {
//			self.state = .changed
//		}
		
		if self.state == .possible {
			if !self.incrementalTransform.isIdentity {
				if let eventTouches = event.touches(for: self), eventTouches.count > 1 || (sqrt(self.incrementalTransform.tx*self.incrementalTransform.tx + self.incrementalTransform.ty*self.incrementalTransform.ty) > 5) {
					self.state = .began
				}
			}
		}
		else {
			self.state = .changed
		}

	}
	
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
		
		if let eventTouches = event.touches(for: self) {
			self.updateOriginalTransform(for: eventTouches)
		}
		
		self.removeFromCache(touches)
		
		guard var remainingTouches = event.touches(for: self) else { return }
		remainingTouches.subtract(touches)
		cacheBeginPoint(for: remainingTouches)
		
		if remainingTouches.isEmpty && self.state.rawValue > UIGestureRecognizer.State.possible.rawValue {
			self.state = .ended
		}
	}
	
	override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
		self.touchesEnded(touches, with: event)
	}
	
	override func reset() {
		self.touchBeginPoints.removeAll()
		self.originalTransform = .identity
		self.incrementalTransform = .identity
	}
	
	func incrementalTransform(with touches: Set<UITouch>) -> CGAffineTransform {
		let sortedTouches = touches.sorted { $0.hash < $1.hash }
		let numTouches = sortedTouches.count
		
		//No touches
		if numTouches == 0 {
			return .identity
		}
		
		//Single touch
		if numTouches == 1 {
			guard let touch = sortedTouches.first,
			let beginPoint = touchBeginPoints[touch]
				else {
					return .identity
			}
			let currentPoint = touch.location(in: self.view?.superview)
			return CGAffineTransform(translationX: currentPoint.x - beginPoint.x, y: currentPoint.y - beginPoint.y)
		}
		
		//If two or more touches, go with the first two (sorted by address)
		let touch1 = sortedTouches[0]
		let touch2 = sortedTouches[1]
		let beginPoint1 = touchBeginPoints[touch1]!
		let currentPoint1 = touch1.location(in: self.view?.superview)
		let beginPoint2 = touchBeginPoints[touch2]!
		let currentPoint2 = touch2.location(in: self.view?.superview)
		
		let layerX = self.view!.center.x
		let layerY = self.view!.center.y
		
		let x1 = beginPoint1.x - layerX
		let y1 = beginPoint1.y - layerY
		let x2 = beginPoint2.x - layerX
		let y2 = beginPoint2.y - layerY
		let x3 = currentPoint1.x - layerX
		let y3 = currentPoint1.y - layerY
		let x4 = currentPoint2.x - layerX
		let y4 = currentPoint2.y - layerY
		
		// Solve the system:
		//   [a b t1, -b a t2, 0 0 1] * [x1, y1, 1] = [x3, y3, 1]
		//   [a b t1, -b a t2, 0 0 1] * [x2, y2, 1] = [x4, y4, 1]
		
		let d = (y1-y2)*(y1-y2) + (x1-x2)*(x1-x2);
		if d < 0.1 {
			return CGAffineTransform(translationX: x3-x1, y: y3-y1)
		}
		
		let a = (y1-y2)*(y3-y4) + (x1-x2)*(x3-x4);
		let b = (y1-y2)*(x3-x4) - (x1-x2)*(y3-y4);
		let tx = (y1*x2 - x1*y2)*(y4-y3) - (x1*x2 + y1*y2)*(x3+x4) + x3*(y2*y2 + x2*x2) + x4*(y1*y1 + x1*x1);
		let ty = (x1*x2 + y1*y2)*(-y4-y3) + (y1*x2 - x1*y2)*(x3-x4) + y3*(y2*y2 + x2*x2) + y4*(y1*y1 + x1*x1);
		return CGAffineTransform(a: a/d, b: -b/d, c: b/d, d: a/d, tx: tx/d, ty: ty/d)
	}
	
	func updateOriginalTransform(for touches: Set<UITouch>) {
		if !touches.isEmpty {
			self.incrementalTransform = self.incrementalTransform(with: touches)
			self.originalTransform = originalTransform.concatenating(incrementalTransform)
			self.incrementalTransform = .identity
		}
	}
	
	func cacheBeginPoint(for touches: Set<UITouch>) {
		if !touches.isEmpty {
			touches.forEach { touch in
				self.touchBeginPoints[touch] = touch.location(in: self.view?.superview)
			}
		}
	}
	
	func removeFromCache(_ touches: Set<UITouch>) {
		touches.forEach { touch in
			self.touchBeginPoints.removeValue(forKey: touch)
		}
	}
	
	
	
}
