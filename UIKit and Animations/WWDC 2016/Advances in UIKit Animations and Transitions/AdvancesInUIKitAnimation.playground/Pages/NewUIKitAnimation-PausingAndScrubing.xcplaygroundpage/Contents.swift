//: [Previous](@previous)

//: ## NewUIKitAnimation-PausingAndScrubing

import UIKit
import PlaygroundSupport

class MyViewController : UIViewController {
	
	var animator: UIViewPropertyAnimator!
	
	var shape: UIView!
	var progress: UIProgressView!
	
	override func loadView() {
		let view = UIView()
		view.backgroundColor = .white
		
		self.shape = UIView()
		shape.frame = CGRect(x: 150, y: 50, width: 100, height: 100)
		shape.backgroundColor = .orange
		view.addSubview(shape)
		self.view = view
		
		self.progress = UIProgressView(frame: CGRect(x: 10, y: 20, width: 350, height: 20))
//		self.progressAnimator.progress = 0.5
		self.view.addSubview(progress)
		
		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureAction(_:)))
		self.shape.addGestureRecognizer(tapGesture)
		
		let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureAction(_:)))
		self.progress.addGestureRecognizer(panGesture)
		self.progress.isUserInteractionEnabled = true
	}
	
	override func viewWillAppear(_ animated: Bool) {
		
		let timing = UICubicTimingParameters(animationCurve: .easeInOut)
		self.animator = UIViewPropertyAnimator(duration: 2.0, timingParameters: timing)
		
		animator.addAnimations {
			self.shape.center.y = 500
			self.shape.transform = CGAffineTransform(rotationAngle: CGFloat.pi/2).concatenating(CGAffineTransform(scaleX: 1.5, y: 1.5))
			
			self.progress.progress = 1
		}
		
		
		
		animator.addCompletion { (options) in
			self.shape.backgroundColor = .green
		}
		
		animator.startAnimation(afterDelay: 1.0)
		
	}
	
	
	@objc func tapGestureAction(_ sender: UITapGestureRecognizer) {
	
		switch self.animator.state {
		case .active:
			
			if animator.isRunning {
				animator.pauseAnimation()
			}
			else {
				animator.addAnimations {
					self.shape.transform = CGAffineTransform.identity
				}
				animator.startAnimation()
			}
			
		default:
			break
		}
	}
	
	@objc func panGestureAction(_ sender: UIPanGestureRecognizer) {
		let s = sender.location(in: sender.view)
		let f = min(s.x/sender.view!.bounds.width, 1.0)
		let fraction = max(0.0, f)
		animator.fractionComplete = fraction
		
	}
	
}

// Present the view controller in the Live View window
PlaygroundPage.current.liveView = MyViewController()


//: [Next](@next)
