//: ## [Previous](@previous)


//: ## From Gesture to Animation

//: ### 2. Using UIDynamicAnimator



import UIKit
import PlaygroundSupport

class MyViewController : UIViewController {
	
	var dynamicAnimator: UIDynamicAnimator?
	var collisionBehavior: UICollisionBehavior!
	var dynamicItemBehavior: UIDynamicItemBehavior!
	
	
	override func loadView() {
		
		let parentView = UIView(frame: CGRect(x: 0, y: 0, width: 1000, height: 500))
		parentView.backgroundColor = .black
		
		self.view = parentView
		
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		dynamicAnimator = UIDynamicAnimator(referenceView: self.view)
		
		let position1 = CGPoint(x: 30, y: 100)
		let view1 = self.configureView(at: position1)
		
		let position2 = CGPoint(x: 130, y: 100)
		let view2 = self.configureView(at: position2)
		
		let position3 = CGPoint(x: 230, y: 100)
		let view3 = self.configureView(at: position3)
		
		dynamicItemBehavior = UIDynamicItemBehavior(items: [])
		dynamicItemBehavior.resistance = 3.0
		dynamicItemBehavior.angularResistance = 3.0
		
		collisionBehavior = UICollisionBehavior(items: [view1, view2, view3])
		collisionBehavior.translatesReferenceBoundsIntoBoundary = true
		
		dynamicAnimator?.addBehavior(dynamicItemBehavior)
		dynamicAnimator?.addBehavior(collisionBehavior)
		
	}
	
	func configureView(at position: CGPoint) -> UIView {
		let view = UIView(frame: CGRect(x: position.x, y: position.y, width: 100, height: 100))
		view.backgroundColor = UIColor(red: 39/255, green: 129/255, blue: 168/255, alpha: 1)
		
		self.view.addSubview(view)
		
		let pangGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGestureAction(_:)))
		view.addGestureRecognizer(pangGestureRecognizer)
		
		return view
	}
	
	@objc func panGestureAction(_ sender: UIPanGestureRecognizer) {
		
		
		guard let targetView = sender.view else { return }
		
		switch sender.state {
			
		case .began:
			dynamicItemBehavior.removeItem(targetView)
			collisionBehavior.removeItem(targetView)
			
		case .changed:
			let translation = sender.translation(in: targetView.superview)
			
			targetView.center.x += translation.x
			targetView.center.y += translation.y
			sender.setTranslation(CGPoint.zero, in: self.view)
			
		case.ended:
			let velocity = sender.velocity(in: targetView.superview)
			collisionBehavior.addItem(targetView)
			dynamicItemBehavior.addItem(targetView)
			dynamicItemBehavior.addLinearVelocity(velocity, for: targetView)
			
		default: break
			
		}
	}
	
	
}



// Present the view controller in the Live View window
PlaygroundPage.current.liveView = MyViewController()
PlaygroundPage.current.needsIndefiniteExecution = true



//: ## [Next](@next)
