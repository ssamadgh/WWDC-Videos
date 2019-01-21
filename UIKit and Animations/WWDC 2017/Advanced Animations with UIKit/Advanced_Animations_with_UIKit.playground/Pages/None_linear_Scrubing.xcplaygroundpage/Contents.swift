//: [Previous](@previous)

import UIKit
import PlaygroundSupport

class MyViewController : UIViewController {
	
	var animator: UIViewPropertyAnimator!
	var animator2: UIViewPropertyAnimator!

	var shape: UIView!
	var shape2: UIView!

	override func loadView() {
		let view = UIView()
		view.backgroundColor = .white
		
		self.shape = UIView()
		shape.frame = CGRect(x: 50, y: 50, width: 100, height: 100)
		shape.backgroundColor = .orange
		
		self.shape2 = UIView()
		shape2.frame = CGRect(x: 200, y: 50, width: 100, height: 100)
		shape2.backgroundColor = .blue

		view.addSubview(shape)
		view.addSubview(shape2)

		self.view = view
		
		let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureAction(_:)))
		self.view.addGestureRecognizer(panGesture)
		
	}
	
	@objc func panGestureAction(_ sender: UIPanGestureRecognizer) {
		let distance: CGFloat = 200.0
		switch sender.state {
		case .began:
			animator = UIViewPropertyAnimator(duration: 1.0, curve: .easeOut, animations: {
				self.shape.frame = self.shape.frame.offsetBy(dx: 0, dy: distance)
				self.shape.alpha = 0
			})
			animator.scrubsLinearly = false
			animator.pauseAnimation()
			
			animator2 = UIViewPropertyAnimator(duration: 1.0, curve: .easeOut, animations: {
				self.shape2.frame = self.shape2.frame.offsetBy(dx: 0, dy: distance)
				self.shape2.alpha = 0
			})
			animator2.scrubsLinearly = true
			animator2.pauseAnimation()

		case .changed:
			let translation = sender.translation(in: self.shape)
			
			animator.fractionComplete = translation.y/distance
			
			let translation2 = sender.translation(in: self.shape2)
			animator2.fractionComplete = translation2.y/distance

			
		case .ended:
			animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
			animator2.continueAnimation(withTimingParameters: nil, durationFactor: 0)

		default:
			break
		}
	}
	
}
// Present the view controller in the Live View window
PlaygroundPage.current.liveView = MyViewController()

//: [Next](@next)
