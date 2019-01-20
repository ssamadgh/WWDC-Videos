//: # Building Interruptible and Responsive Interactions

//: ## From Gesture to Animation

//: ### 1. Using Gesture Recognizer

import UIKit
import PlaygroundSupport

class MyViewController : UIViewController {
	
    override func loadView() {
		let parentView = UIView(frame: CGRect(x: 0, y: 0, width: 1000, height: 500))
        parentView.backgroundColor = .black

		let view = UIView(frame: CGRect(x: 100, y: 100, width: 100, height: 100))
		view.backgroundColor = UIColor(red: 39/255, green: 129/255, blue: 168/255, alpha: 1)

        parentView.addSubview(view)
        self.view = parentView
		
		let pangGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGestureAction(_:)))
		view.addGestureRecognizer(pangGestureRecognizer)
    }
	
	@objc func panGestureAction(_ sender: UIPanGestureRecognizer) {
		
		switch sender.state {
		case .began, .changed:
			
			let translation = sender.translation(in: self.view)
			sender.view?.center.x += translation.x
			sender.view?.center.y += translation.y
			sender.setTranslation(CGPoint.zero, in: self.view)

		case.ended:
			let duration: Double = 1.5
			let velocity = sender.velocity(in: self.view)
			let maxDistance: CGFloat = 50
			
			let xDistance: CGFloat = self.distance(forVelocity: velocity.x, duration: duration, maxDistance: maxDistance)
			let yDistance: CGFloat = self.distance(forVelocity: velocity.y, duration: duration, maxDistance: maxDistance)

			let xVelocity = velocity.x/xDistance
			let yVelocity = velocity.y/yDistance
			
			UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: xVelocity, options: UIView.AnimationOptions(), animations: {
				
				sender.view?.center.x += xDistance
				
			}, completion: nil)
			
			UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: yVelocity, options: UIView.AnimationOptions(), animations: {
				
				sender.view?.center.y += yDistance
				
			}, completion: nil)

			
		default: break
			
		}
	}
	
	
	func distance(forVelocity velocity: CGFloat, duration: Double, maxDistance: CGFloat) -> CGFloat {
		guard velocity != 0 else { return 0 }
		let unique = (velocity)/abs(velocity)
		let distance: CGFloat = unique * min(abs(velocity)*CGFloat(duration)/2, abs(maxDistance))
		return distance
	}

}

let parentView = UIView(frame: CGRect(x: 0, y: 0, width: 1000, height: 500))




// Present the view controller in the Live View window
PlaygroundPage.current.liveView = MyViewController()
PlaygroundPage.current.needsIndefiniteExecution = true


//: ## [Next](@next)
