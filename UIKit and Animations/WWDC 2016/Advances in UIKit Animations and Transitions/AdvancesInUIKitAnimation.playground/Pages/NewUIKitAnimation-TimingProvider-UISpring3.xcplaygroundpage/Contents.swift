//: [Previous](@previous)

//: ## NewUIKitAnimation-TimingProvider-UISpring3

import UIKit
import PlaygroundSupport

class MyViewController : UIViewController {
	
	var shape: UIView!
	var shapePosition: CGPoint! = .zero

	override func loadView() {
		let view = UIView()
		view.backgroundColor = .white
		
		self.shape = UIView()
		shape.frame = CGRect(x: 170, y: 270, width: 100, height: 100)
		self.shapePosition = shape.center
		
		shape.backgroundColor = .orange
		view.addSubview(shape)
		self.view = view
		
		let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureAction(_:)))
		self.shape.addGestureRecognizer(panGesture)

		
	}
	
	override func viewWillAppear(_ animated: Bool) {
		
		
	}
	
	@objc func panGestureAction(_ sender: UIPanGestureRecognizer) {
		
		switch sender.state {
		case .began, .changed:
			
			let translation = sender.translation(in: self.view)
			self.shape.center.x += translation.x
			self.shape.center.y += translation.y
			
			sender.setTranslation(CGPoint.zero, in: self.view)
			
		case .ended:
			
			let current = self.shape.center
			let dx = diff(current: current.x, initial: self.shapePosition.x)
			let dy = diff(current: current.y, initial: self.shapePosition.y)
			let velocity = CGVector(dx: dx, dy: dy)
			
			let timing = UISpringTimingParameters(dampingRatio: 0.5, initialVelocity: velocity)
			
			let animator = UIViewPropertyAnimator(duration: 1.5, timingParameters: timing)
			
			animator.addAnimations {
				self.shape.center = self.shapePosition
			}
			
			animator.startAnimation()

			
		default:
			break
		}
		
		
	}
	
	func diff(current: CGFloat, initial: CGFloat) -> CGFloat {
		let value = current - initial
		guard value != 0 else { return 0 }
		let diff = (value)/abs(value)
		return diff
	}

}

// Present the view controller in the Live View window
PlaygroundPage.current.liveView = MyViewController()

//: [Next](@next)
