//
//  ViewController.swift
//  UIKitRendering
//
//  Created by Seyed Samad Gholamzadeh on 8/24/1396 AP.
//  Copyright © 1396 AP Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

let maxRotation = 0.1
class ViewController: UIViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		
		let image = #imageLiteral(resourceName: "frog")
		
		let origin = CGPoint(x: 30, y: 30)
		let imageView = self.createImageView(for: image, origin: origin)
		self.view.addSubview(imageView)
		
		var origin2 = origin
		origin2.y = 100 + imageView.frame.size.height
		let fastImageView = self.createFastImageView(for: image, origin: origin2)
		self.view.addSubview(fastImageView)
	}
	
	func createImageView(for image: UIImage, origin: CGPoint) -> UIImageView {
		let imageView = UIImageView(image: image)
		imageView.contentMode = .scaleAspectFit
		
		//Add a shadow around the image.
		
		imageView.bounds.size = image.size
		imageView.layer.shadowOffset = CGSize(width: 10, height: 10)
		imageView.layer.shadowColor = UIColor.black.cgColor
		imageView.layer.shadowOpacity = 0.5
		
		//Rotate the image by some small random angle.
		imageView.transform = CGAffineTransform(rotationAngle: 0.1)
		
		// The image view may be rotated, so set its frame in terms of the identity transform and then reapply the transform.
		let imageViewTransform = imageView.transform
		imageView.transform = CGAffineTransform.identity
		imageView.frame = CGRect(origin: origin, size: imageView.image!.size)
		imageView.transform = imageViewTransform
		
		return imageView
	}
	
	func createFastImageView(for image: UIImage, origin: CGPoint) -> UIImageView {
		let imageView = UIImageView(image: image)
		imageView.contentMode = .scaleAspectFit
		
		//Add a shadow around the image.
		
		imageView.bounds.size = image.size
		imageView.layer.shadowOffset = CGSize(width: 10, height: 10)
		imageView.layer.shadowColor = UIColor.black.cgColor
		imageView.layer.shadowOpacity = 0.5
		
		//Rotate the image by some small random angle.
		//		let randomAngle = arc4random()
		imageView.transform = CGAffineTransform(rotationAngle: 0.1)
		
		//Rather than using Core Animation's edge antialiasing, which requires an off-screen rendering pass, We'll draw our image into an image with an empty 1px border on each side. That way, when it's rotated, the edges will appear smooth because the outermost pixels of the original image will be sampled with the clear pixels in the outer border we add. This sampling is much faster but not as high-quality.
		
		let imageSizeWithBorder = CGSize(width: image.size.width + 2, height: image.size.height + 2)
		UIGraphicsBeginImageContext(imageSizeWithBorder)

		//The image starts off filled with clear pixels, so we don't need to explicity fill them here.
		image.draw(in: CGRect(origin: CGPoint(x: 1, y: 1), size: image.size))
		imageView.image = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		
		//We no longer need CA's edge antialiasing on this layer.
		imageView.layer.allowsEdgeAntialiasing = false
		
		// The image view may be rotated, so set its frame in terms of the identity transform and then reapply the transform.
		let imageViewTransform = imageView.transform
		imageView.transform = CGAffineTransform.identity
		imageView.frame = CGRect(origin: origin, size: imageView.image!.size)
		imageView.transform = imageViewTransform
		
		// Save Core Animation a pass to figure out where the transparent pixels are by informing it explicity of the content's shape.
		let oldPath = imageView.layer.shadowPath
		imageView.layer.shadowPath = UIBezierPath(rect: imageView.bounds).cgPath

		
		// Since the layer's delegate (its UIView) will not create an action for this change (via the CALayerDelegate method actionForLayer:forKey:), We must explicity ceate the animation between these values.
		let pathAnimation = CABasicAnimation(keyPath: "shadowPath")
		pathAnimation.fromValue = oldPath
		pathAnimation.toValue = imageView.layer.shadowPath
		pathAnimation.duration = 1
		pathAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
		pathAnimation.isRemovedOnCompletion = true
		imageView.layer.add(pathAnimation, forKey: "shadowPath")
		
		return imageView
	}

	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
//		addReflection(isReflection: true)
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	
	
}

