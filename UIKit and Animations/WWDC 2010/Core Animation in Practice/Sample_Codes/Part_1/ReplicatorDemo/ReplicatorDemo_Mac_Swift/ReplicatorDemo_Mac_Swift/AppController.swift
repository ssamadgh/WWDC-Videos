//
//  AppController.swift
//  ReplicatorDemo_Swift
//
//  Created by Seyed Samad Gholamzadeh on 3/9/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import AppKit

class AppController: NSObject {
	
	var z_time_Delay: CFTimeInterval = CFTimeInterval(0.15)
	var x_time_Delay: CFTimeInterval { return z_time_Delay*5 }
	var y_time_Delay: CFTimeInterval { return x_time_Delay*6 }

	
	@IBOutlet weak var view: NSView!
	var rootLayer: CALayer!
	var replicatorX: CAReplicatorLayer!
	var replicatorY: CAReplicatorLayer!
	var replicatorZ: CAReplicatorLayer!
	var subLayer: CALayer!
	

	override func awakeFromNib() {
		
		//Create the root layer
		rootLayer = CALayer()
		
		//Set the root layer's attributes
		var color = CGColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1)
		rootLayer.backgroundColor = color

		//Create a 3D perspective transform
		var t = CATransform3DIdentity
		t.m34 = 1.0 / -900.0
		
		//Rotate and reposition the camera
		t = CATransform3DTranslate(t, 0, 40, -210)
		t = CATransform3DRotate(t, 0.3, 1.0, -1.0, 0)
		rootLayer.sublayerTransform = t;
		
		//Create the replicator layer
		replicatorX = CAReplicatorLayer()
		
		//Set the replicator's attributes
		replicatorX.frame = CGRect(x: 0, y: 0, width: 400, height: 400)
		replicatorX.position = CGPoint(x: 320, y: 320)
		replicatorX.instanceDelay = x_time_Delay
		replicatorX.preservesDepth = true
		replicatorX.zPosition = 200
		replicatorX.anchorPointZ = -160
		
		//Create the second level of replicators
		replicatorY = CAReplicatorLayer()
		
		//Set the second replicator's attributes
		replicatorY.instanceDelay = y_time_Delay
		replicatorY.preservesDepth = true
		
		//Create the third level of replicators
		replicatorZ = CAReplicatorLayer()
		
		//Set the third replicator's attributes
		color = CGColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)
		replicatorZ.instanceColor = color
		replicatorZ.instanceDelay = z_time_Delay
		replicatorZ.preservesDepth = true
		
		//Create a sublayer
		subLayer = CALayer()
		subLayer.frame = CGRect(x: 0, y: 0, width: 40, height: 30)
		subLayer.position = CGPoint(x: 90, y: 265)
		color = CGColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1)
		subLayer.borderColor = color
		subLayer.borderWidth = 2.0
		color = CGColor(red: 1, green: 1, blue: 1, alpha: 1)
		subLayer.backgroundColor = color
		subLayer.cornerRadius = 5

		//Set up the sublayer/replicator hierarchy
		replicatorZ.addSublayer(subLayer)
		replicatorY.addSublayer(replicatorZ)
		replicatorX.addSublayer(replicatorY)
		
		//Add the replicator to the root layer
		rootLayer.addSublayer(replicatorX)
		
		//Set the view's layer to the base layer
		view.layer = rootLayer
		view.wantsLayer = true
		//Force the view to update
		view.setNeedsDisplay(view.visibleRect)
		
		//Transform matrix to be used for camera animation
		t = CATransform3DMakeRotation(1, 0, 1, 0)
		
		//Animate the camera panning left and right continuously
		let animation = CABasicAnimation()
		animation.fromValue = NSValue(caTransform3D: CATransform3DIdentity)
		animation.toValue = NSValue(caTransform3D: t)
		animation.duration = 5
		animation.isRemovedOnCompletion = false
		animation.autoreverses = true
		animation.repeatCount = 1e100
		animation.fillMode = kCAFillModeForwards
		replicatorX.add(animation, forKey: "transform")
		
		Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(addOffsets(_:)), userInfo: nil, repeats: false)
		Timer.scheduledTimer(timeInterval: 9.5, target: self, selector: #selector(animate(_:)), userInfo: nil, repeats: false)
	}
	
	//Animates the layers by having them rotate and fly past the camera.
	@objc func animate(_ sender: Any) {
		//Dont implicitly animate the delay change
		CATransaction.setDisableActions(true)
		
		//Reset the replicator delays to their origonal values
		replicatorX.instanceDelay = x_time_Delay
		replicatorY.instanceDelay = y_time_Delay
		replicatorZ.instanceDelay = z_time_Delay
		
		//Re-enable the implicit animations
		CATransaction.setDisableActions(false)
		
		//Create the transform matrix for the animation
		
		//Move forward 1000 units along z-axis
		var t = CATransform3DMakeTranslation(0, 0, 1000)
		
		//Rotate Pi radians about the axis (0.7, 0.3, 0.0)
		t = CATransform3DRotate(t, CGFloat.pi, 0.7, 0.3, 0.0)
		
		//Scale the X and Y dimmensions by a factor of 3
		t = CATransform3DScale(t, 3, 3, 1)
		
		//Transform Animation
		var animation = CABasicAnimation()
		animation.fromValue = NSValue(caTransform3D: CATransform3DIdentity)
		animation.toValue = NSValue(caTransform3D: t)
		animation.duration = 1.0
		animation.isRemovedOnCompletion = false
		animation.fillMode = kCAFillModeBoth
		subLayer.add(animation, forKey: "transform")
		
		//Opacity Animation
		animation = CABasicAnimation()
		animation.fromValue = NSNumber(value: 1.0)
		animation.toValue = NSNumber(value: 0.0)
		animation.duration = 1.0
		animation.isRemovedOnCompletion = false
		animation.fillMode = kCAFillModeBoth
		subLayer.add(animation, forKey: "opacity")
		
		//Start a timer to call 'reset:' once the animation has completed
		Timer.scheduledTimer(timeInterval: y_time_Delay * 5.0 + 0.5, target: self, selector: #selector(reset(_:)), userInfo: nil, repeats: false)
	}
	
	
	//Animate the layers back into the original cube formation
	@objc func reset(_ sender: Any) {
		
		//Create the transform matrix for the animation
		
		//Move forward 1000 units along z-axis
		var t = CATransform3DMakeTranslation(0, 0, 1000)
		
		//Rotate Pi radians about the axis (0.7, 0.3, 0.0)
		t = CATransform3DRotate(t, CGFloat.pi, 0.7, 0.3, 0.0)
		
		//Scale the X and Y dimmensions by a factor of 3
		t = CATransform3DScale(t, 3, 3, 1);
		
		//Dont implicitly animate the delay change
		CATransaction.setDisableActions(true)
		
		//Set the delays lower for a faster animation
		replicatorX.instanceDelay = 0.1
		replicatorY.instanceDelay = 0.6
		replicatorZ.instanceDelay = -z_time_Delay
		
		//Re-enable the implicit animations
		CATransaction.setDisableActions(false)
		
		//Transform Animation
		var animation = CABasicAnimation()
		animation.fromValue = NSValue(caTransform3D: t)
		animation.toValue = NSValue(caTransform3D: CATransform3DIdentity)
		animation.duration = 1.0
		animation.isRemovedOnCompletion = false
		animation.fillMode = kCAFillModeBoth
		subLayer.add(animation, forKey: "transform")
		
		//Opacity Animation
		animation = CABasicAnimation()
		animation.fromValue = NSNumber(value: 0.0)
		animation.toValue = NSNumber(value: 1.0)
		animation.duration = 1.0
		animation.isRemovedOnCompletion = false
		animation.fillMode = kCAFillModeBoth
		subLayer.add(animation, forKey: "opacity")
		
		//Start a timer to call 'animate:' once the animation has completed
		Timer.scheduledTimer(timeInterval: 0.6 * 5.0 + 2.0, target: self, selector: #selector(animate(_:)), userInfo: nil, repeats: false)
	}
	
	
	//Activtes each replicator one by one using timers to control when each starts
	// (Used for the intro sequnce where a single layer expands into the 3D cube)
	@objc func addOffsets(_ sender: Any) {
		Timer.scheduledTimer(timeInterval: 0, target: self, selector: #selector(addZReplicator(_:)), userInfo: nil, repeats: false)
		Timer.scheduledTimer(timeInterval: 2.6, target: self, selector: #selector(addYReplicator(_:)), userInfo: nil, repeats: false)
		Timer.scheduledTimer(timeInterval: 5.2, target: self, selector: #selector(addXReplicator(_:)), userInfo: nil, repeats: false)


	}
	
	//Activtes the X replicator by settign its instance count and instance transform
	// (Used for the intro sequnce where a single layer expands into the 3D cube)
	@objc func addXReplicator(_ sender: Any) {
		CATransaction.setDisableActions(true)
		replicatorX.instanceCount = 6
		replicatorX.instanceRedOffset = -0.2
		CATransaction.setDisableActions(false)
		CATransaction.setAnimationDuration(2.5)
		replicatorX.instanceTransform = CATransform3DMakeTranslation(60, 0, 0)
	}
	
	//Activtes the Y replicator by settign its instance count and instance transform
	// (Used for the intro sequnce where a single layer expands into the 3D cube)
	@objc func addYReplicator(_ sender: Any) {
		CATransaction.setDisableActions(true)
		replicatorY.instanceCount = 5
		replicatorY.instanceBlueOffset = -0.2
		CATransaction.setDisableActions(false)
		CATransaction.setAnimationDuration(2.5)
		replicatorY.instanceTransform = CATransform3DMakeTranslation(0, -50, 0)
	}

	
	//Activtes the Z replicator by settign its instance count and instance transform
	// (Used for the intro sequnce where a single layer expands into the 3D cube)
	@objc func addZReplicator(_ sender: Any) {
		CATransaction.setDisableActions(true)
		replicatorZ.instanceCount = 5
		replicatorZ.instanceGreenOffset = -0.2
		CATransaction.setDisableActions(false)
		CATransaction.setAnimationDuration(2.5)
		replicatorZ.instanceTransform = CATransform3DMakeTranslation(0, 0, -80)
	}


	
}
