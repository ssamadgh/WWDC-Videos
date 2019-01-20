//
//  ViewController.swift
//  CAShapeLayer&CAAction
//
//  Created by Seyed Samad Gholamzadeh on 10/17/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
	
	@IBOutlet weak var button: UIButton!
	
	@IBOutlet weak var myView: MyView!
	var layer: CAShapeLayer!
	override func loadView() {
		super.loadView()
	}
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		
		self.layer = CAShapeLayer()
		
		let path = UIBezierPath(arcCenter: CGPoint(x: 100, y: 100), radius: 50, startAngle: 0, endAngle: CGFloat.pi*2, clockwise: true)
		
//		path.stroke()
//		path.move(to: CGPoint(x: 100, y: 100))
//		path.addLine(to: CGPoint(x: 500, y: 100))
//		path.close()
		
		layer.path = path.cgPath
		layer.lineWidth = 10
		layer.strokeEnd = 0.1
		layer.lineCap = .round
		layer.strokeColor = UIColor.red.cgColor
		layer.fillColor = UIColor.clear.cgColor
		self.view.layer.addSublayer(layer)
		
	}
	
	@IBAction func downloadButtonAction(_ sender: UIButton) {
		let animation = CABasicAnimation(keyPath: "strokeEnd")
		animation.fromValue = 0.1
		animation.toValue = 1.0
		animation.duration = 0.5
		animation.isRemovedOnCompletion = false
		self.layer.strokeEnd = 1.0

		self.layer.add(animation, forKey: "strokeEnd")
		
		UIView.animate(withDuration: 5) {
			self.myView.layer.opacity = Float.random(in: 0...1)
		}
		
	}

	
}

class MyView: UIView {
	
	public override func action(for layer: CALayer, forKey event: String) -> CAAction? {
		if event == "opacity" {
			return Action()
		}
		
		return super.action(for: layer, forKey: event)
	}
	
}


class Action: NSObject, CAAction {
	
	func run(forKey event: String, object anObject: Any, arguments dict: [AnyHashable : Any]?) {
		if event == "opacity" {
			let layer = anObject as! CALayer
			let colorAnim = CABasicAnimation(keyPath: "backgroundColor")
			colorAnim.duration = 0.5
			colorAnim.fromValue = layer.presentation()!.backgroundColor
			let newColor = UIColor(hue: CGFloat(layer.opacity), saturation: 1, brightness: 1, alpha: 1).cgColor
			layer.opacity = 1

			colorAnim.toValue = newColor
			colorAnim.fillMode = .forwards
			colorAnim.isRemovedOnCompletion = false
			layer.backgroundColor = newColor
			layer.add(colorAnim, forKey: "colorAnim")
		}
	}
}
