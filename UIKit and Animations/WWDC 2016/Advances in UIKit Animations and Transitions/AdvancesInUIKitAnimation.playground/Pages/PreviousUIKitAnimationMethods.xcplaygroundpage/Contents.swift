//: # AdvancesInUIKitAnimation

//: ## PreviousUIKitAnimationMethods

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
		
		
		UIView.animate(withDuration: 2.0, delay: 1.0, options: [.curveEaseInOut], animations: {
			self.shape.center.y = 500
		}, completion: nil)
		
	}
	
	override func viewWillAppear(_ animated: Bool) {
		UIView.animate(withDuration: 2.0, delay: 1.0, options: [.curveEaseInOut], animations: {
			self.shape.center.y = 500
		}, completion: nil)
		
	}
}

// Present the view controller in the Live View window
PlaygroundPage.current.liveView = MyViewController()

//: [Next](@next)
