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
		
//		let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureAction(_:)))
//		self.shape.addGestureRecognizer(panGesture)
		
		animateTransitionIfNeeded(duration: 5)
	}
	
	func animateTransitionIfNeeded(duration: TimeInterval) {
		guard animator == nil || animator?.state != .active else { return }
		animator = UIViewPropertyAnimator(duration: duration, curve: .easeInOut, animations: {
			
			for _ in 0..<20 {
				let rotation = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
				self.shape.transform = self.shape.transform.concatenating(rotation)
			}
			
		})
		animator.startAnimation()
	}
	
}
// Present the view controller in the Live View window
PlaygroundPage.current.liveView = MyViewController()

//: [Next](@next)
