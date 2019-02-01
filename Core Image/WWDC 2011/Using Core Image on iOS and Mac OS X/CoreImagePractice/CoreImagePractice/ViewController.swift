//
//  ViewController.swift
//  CoreImagePractice
//
//  Created by Seyed Samad Gholamzadeh on 8/1/1396 AP.
//  Copyright © 1396 AP Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit
//import CoreImage
//import AVFoundation

class ViewController: UIViewController {

	@IBOutlet var imageView: UIImageView!
	
	var set: Set<Int> = []
	var previousNumber: Int = 0
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		JPTiltShift.register()

	}
	
	override func viewDidAppear(_ animated: Bool) {
		self.imageView.image = UIImage(named: "image2")
		self.detectFace()
//		self.detectFaceAndDrawFaceBox()
//		self.adjustImage()
	}
	
	func setFilterForImage() {
		let image = self.imageView.image
		
		
		let url = Bundle.main.url(forResource: "IMG_7169", withExtension: "jpg")
		let imageX = CIImage(contentsOf: url!)!
		
		
		let properties = imageX.properties
		print("properties", properties)

		DispatchQueue.global().async {
			let ciImage = CIImage(image: image!)
//			let properties = ciImage?.properties
//			print("properties", properties)
			/// Create Filter
			let sepiaTone = "CISepiaTone"
			let filter: CIFilter! = CIFilter(name: sepiaTone)
			
			if filter != nil {

				filter.setValue(ciImage, forKey: kCIInputImageKey)
				filter.setValue(NSNumber(value: 0.6), forKey: kCIInputIntensityKey)
			}
			
			// Create CIContext
			let context = CIContext(options: [kCIContextUseSoftwareRenderer: true])

//			let context = CIContext()
			let result = filter.outputImage!

			let cgiImage = context.createCGImage(result, from: result.extent)!
			DispatchQueue.main.async {
//				let eagle_ctx = EAGLContext(api: EAGLRenderingAPI.openGLES2)
//				let ciContext = CIContext(eaglContext: eagle_ctx!)
//
//				ciContext.draw(result, in: self.view.bounds, from: result.extent)

//				self.imageView.image = UIImage(cgImage: cgiImage)
				
				self.imageView.image = UIImage(cgImage: cgiImage, scale: 1, orientation: UIImageOrientation.down)
//				self.imageView.image = UIImage(ciImage: result)
			}

		}
	}
	
	func detectFace() {
		let detector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])!
		let image = CIImage(image: self.imageView.image!)!
		
		let features = detector.features(in: image, options: [CIDetectorImageOrientation: kCGImagePropertyOrientation])
		
		for feature in features as! [CIFaceFeature] {
			print("\(feature.bounds)")
			
			if feature.hasLeftEyePosition {
				print("left eye: \(feature.leftEyePosition)")
			}
			if feature.hasRightEyePosition {
				print("right eye: \(feature.rightEyePosition)")
			}
			if feature.hasMouthPosition {
				print("mouth: \(feature.mouthPosition)")
			}

		}
	}
	
	func faceBoxImage(for face: CIFaceFeature) -> CIImage {
		let color = CIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.5)
		var image = CIFilter(name: "CIConstantColorGenerator", withInputParameters: ["inputColor" : color])?.outputImage
		image = CIFilter(name: "CICrop", withInputParameters: [kCIInputImageKey : image!, "inputRectangle" : CIVector(cgRect: face.bounds)])?.outputImage
		
		return image!
	}
	
	func detectFaceAndDrawFaceBox() {
		let detector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])!
		
		let url = Bundle.main.url(forResource: "IMG_7169", withExtension: "jpg")
		var ciImage = CIImage(contentsOf: url!)!
		let properties = ciImage.properties
		print("properties", properties)

//		var ciImage = CIImage(image: self.imageView.image!)!
		
		let faces = detector.features(in: ciImage, options: [CIDetectorImageOrientation: 3])
		
		for face in faces as! [CIFaceFeature] {
			ciImage = CIFilter(name: "CISourceOverCompositing", withInputParameters: [kCIInputImageKey: self.faceBoxImage(for: face), kCIInputBackgroundImageKey: ciImage])!.outputImage!
		}
		
		let context = CIContext()
		
		let cgiImage = context.createCGImage(ciImage, from: ciImage.extent)!
		
		self.imageView.image = UIImage(cgImage: cgiImage, scale: 1, orientation: .downMirrored)


	}
	
	
	func adjustImage() {
//		var ciImage = CIImage(image: self.imageView.image!)!
		
		let url = Bundle.main.url(forResource: "IMG_6093", withExtension: "jpg")
		var ciImage = CIImage(contentsOf: url!)!
		let properties = ciImage.properties
		print("properties", properties)
		
		let filters = ciImage.autoAdjustmentFilters(options: [kCIImageAutoAdjustRedEye: false])
		
		for filter in filters {
			print("filter name", filter.name)
			filter.setValue(ciImage, forKey: kCIInputImageKey)
			ciImage = filter.outputImage!
		}
		
		let context = CIContext()
		
		let cgiImage = context.createCGImage(ciImage, from: ciImage.extent)!
		
		self.imageView.image = UIImage(cgImage: cgiImage)
	}
	
//	func saveToLibrary() {
//		let context = CIContext(options: [kCIContextUseSoftwareRenderer: true])
////		UIImageWriteToSavedPhotosAlbum(<#T##image: UIImage##UIImage#>, <#T##completionTarget: Any?##Any?#>, <#T##completionSelector: Selector?##Selector?#>, <#T##contextInfo: UnsafeMutableRawPointer?##UnsafeMutableRawPointer?#>)
//
//		let eagle_ctx = EAGLContext(api: EAGLRenderingAPI.openGLES2)
//		let ciContext = CIContext(eaglContext: eagle_ctx!)
//		glBindRenderbuffer(GLenum(GL_RENDERBUFFER), GLuint(GL_RENDERBUFFER))
//		eagle_ctx?.presentRenderbuffer(Int(GL_RENDERBUFFER))
//	}
	
	
	@IBAction func filterButton(sender: UIButton) {
//		self.setFilterForImage()
//		self.detectFaceAndDrawFaceBox()
		self.adjustImage()
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}


	
	
}

