//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport

class MyViewController : UIViewController {
	
	var animator: UIViewPropertyAnimator!
	var shape: UIView!

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

    }
	
	@objc func panGestureAction(_ sender: UIPanGestureRecognizer) {
		let distance: CGFloat = 200.0
		switch sender.state {
		case .began:
			animator = UIViewPropertyAnimator(duration: 1.0, curve: .easeOut, animations: {
				self.shape.frame = self.shape.frame.offsetBy(dx: 0, dy: distance)
			})
			animator.pauseAnimation()
				
		case .changed:
			let translation = sender.translation(in: self.shape)

			animator.fractionComplete = translation.y/distance
			
		case .ended:
			animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
			
		default:
			break
		}
	}

}
// Present the view controller in the Live View window
PlaygroundPage.current.liveView = MyViewController()
