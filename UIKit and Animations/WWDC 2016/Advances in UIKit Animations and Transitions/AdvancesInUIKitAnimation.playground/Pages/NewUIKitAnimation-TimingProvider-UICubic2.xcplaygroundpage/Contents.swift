//: [Previous](@previous)

//: ## NewUIKitAnimation-TimingProvider-UICubic2

import UIKit
import PlaygroundSupport

class MyViewController : UIViewController {
	
	var shape: UIView!
	
	override func loadView() {
		let view = UIView()
		view.backgroundColor = .white
		
		self.shape = UIView()
		shape.frame = CGRect(x: 150, y: 50, width: 100, height: 100)
		shape.backgroundColor = .orange
		view.addSubview(shape)
		self.view = view
		
		
	}
	
	override func viewWillAppear(_ animated: Bool) {
		
		let timing = UICubicTimingParameters(controlPoint1: CGPoint(x: 0.0, y: 1.0), controlPoint2: CGPoint(x: 1.0, y: 0.0))
		
		let animator = UIViewPropertyAnimator(duration: 2.0, timingParameters: timing)
		
		animator.addAnimations {
			self.shape.center.y = 500
			self.shape.transform = CGAffineTransform(rotationAngle: CGFloat.pi/2)
		}
		
		animator.addCompletion { (_) in
			
			self.shape.backgroundColor = .green
		}
		
		animator.startAnimation(afterDelay: 1.0)
		
	}
}

// Present the view controller in the Live View window
PlaygroundPage.current.liveView = MyViewController()

//: [Next](@next)
