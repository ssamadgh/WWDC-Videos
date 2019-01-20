//: ## [Previous](@previous)

//: ## From Animation to Gesture

//: ### 1. Using Gesture Recognizer


import UIKit
import PlaygroundSupport

class CustomView: UIView {
	
	override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {

		let superViewPoint = self.convert(point, to: superview)
		let point = layer.presentation()?.convert(superViewPoint, from: superview?.layer) ?? point

		return super.hitTest(point, with: event)
	}
	
//	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//		print(touches.first?.location(in: superview))
//		if let presentationPosition = self.layer.presentation()?.position {
//			print("presentationPosition ", presentationPosition)
//			self.center = presentationPosition
//		}
//		self.layer.removeAllAnimations()
//
//	}
	
}


class MyViewController : UIViewController {
	
	
	override func loadView() {
		
		let parentView = UIView(frame: CGRect(x: 0, y: 0, width: 1000, height: 500))
		parentView.backgroundColor = .black
		
		self.view = parentView
		
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		let view = self.configureView(at: CGPoint(x: 100, y: 100))
		
		UIView.animate(withDuration: 10, delay: 0.5, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: UIView.AnimationOptions.allowUserInteraction, animations: {
			
			view.center = CGPoint(x: 100, y: 400)
			
		}, completion: nil)
	}
	
	func configureView(at position: CGPoint) -> UIView {
		let view = CustomView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
		view.center = position
		view.backgroundColor = UIColor(red: 39/255, green: 129/255, blue: 168/255, alpha: 1)
		
		self.view.addSubview(view)
		
		let pangGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGestureAction(_:)))
		view.addGestureRecognizer(pangGestureRecognizer)
		
		return view
	}
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		
		let view = touches.first?.view
		
		if let presentationPosition = view?.layer.presentation()?.position {
			view?.center = presentationPosition
		}
		view?.layer.removeAllAnimations()
		
	}

	
	@objc func panGestureAction(_ sender: UIPanGestureRecognizer) {
		
		
		guard let targetView = sender.view else { return }
		
		switch sender.state {
			
		case .began, .changed:
			let translation = sender.translation(in: targetView.superview)
			
			targetView.center.x += translation.x
			targetView.center.y += translation.y
			sender.setTranslation(CGPoint.zero, in: self.view)
			
		case .ended:
			UIView.animate(withDuration: 10, delay: 0.5, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: UIView.AnimationOptions.allowUserInteraction, animations: {
				
				targetView.center = CGPoint(x: 100, y: 400)
				
			}, completion: nil)

		default: break
			
		}
	}
	
	
}



// Present the view controller in the Live View window
PlaygroundPage.current.liveView = MyViewController()
PlaygroundPage.current.needsIndefiniteExecution = true


//: ## [Next](@next)
