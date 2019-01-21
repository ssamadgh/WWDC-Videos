//: [Previous](@previous)

import UIKit
import PlaygroundSupport

class MyViewController : UIViewController {
	
	var animator: UIViewPropertyAnimator!
	var shape: UIView!
	var progressWhenInterrupted: CGFloat = 0
	let distance: CGFloat = 300.0

	override func loadView() {
		let view = UIView()
		view.backgroundColor = .white
		
		self.shape = UIView()
		shape.frame = CGRect(x: 150, y: 50, width: 100, height: 100)
		shape.backgroundColor = .orange
		view.addSubview(shape)
		self.view = view
		
		let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureAction(_:)))
		self.shape.addGestureRecognizer(panGesture)
		
		animateTransitionIfNeeded(duration: 1.0)

	}
	
	func animateTransitionIfNeeded(duration: TimeInterval) {
		guard animator == nil || animator?.state != .active else { return }
		animator = UIViewPropertyAnimator(duration: duration, curve: .easeIn, animations: {
			self.shape.frame = self.shape.frame.offsetBy(dx: 0, dy: self.distance)
		})
		animator.startAnimation()
	}
	
	@objc func panGestureAction(_ sender: UIPanGestureRecognizer) {
		switch sender.state {
		case .began:
			animateTransitionIfNeeded(duration: 1.0)
			animator.pauseAnimation()
			progressWhenInterrupted = animator.fractionComplete
		case .changed:
			let translation = sender.translation(in: self.shape)
			
			animator.fractionComplete = translation.y/distance + progressWhenInterrupted
			
		case .ended:
			let timing = UICubicTimingParameters(animationCurve: .easeOut)
			animator.continueAnimation(withTimingParameters: timing, durationFactor: 0)
			
		default:
			break
		}
	}
	
}

// Present the view controller in the Live View window
PlaygroundPage.current.liveView = MyViewController()

//: [Next](@next)
