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
	
	let imageName = "green1"
	var set: Set<Int> = []
	var previousNumber: Int = 0
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		JPTiltShift.register()

	}
	
	override func viewDidAppear(_ animated: Bool) {
		let url = Bundle.main.url(forResource: "IMG_6093", withExtension: "jpg")!

		self.imageView.image = UIImage(contentsOfFile: url.path)

	}
	
	
	func chromaKeyFilter() {
		var ciImage = ciImagewith("green3")
		let backgroundImage: CIImage = ciImagewith("IMG_6093")
//		let properties = ciImage.properties
//		print("properties", properties)

		let chromaFilter = colorCubeFilterForChromaKey(hueAngle: 100)
		chromaFilter.setValue(ciImage, forKey: kCIInputImageKey)
		
		let chromaImage = chromaFilter.outputImage!
		
		ciImage = CIFilter(name: "CISourceOverCompositing", withInputParameters: [kCIInputImageKey: chromaImage, kCIInputBackgroundImageKey: backgroundImage])!.outputImage!
		
		let ciContext = CIContext()
		let outputImage = ciContext.createCGImage(ciImage, from: ciImage.extent)!
		self.imageView.image = UIImage(cgImage: outputImage)
	}

	
	
	func RGBtoHSV(r : Float, g : Float, b : Float) -> (h : Float, s : Float, v : Float) {
		var h : CGFloat = 0
		var s : CGFloat = 0
		var v : CGFloat = 0
		let col = UIColor(red: CGFloat(r), green: CGFloat(g), blue: CGFloat(b), alpha: 1.0)
		col.getHue(&h, saturation: &s, brightness: &v, alpha: nil)
		return (Float(h), Float(s), Float(v))
	}
	
	func colorCubeFilterForChromaKey(hueAngle: Float) -> CIFilter {
		
		let hueRange: Float = 60 // degrees size pie shape that we want to replace
//		let min: Float = (hueAngle - hueRange/2.0)
//		let max: Float = (hueAngle + hueRange/2.0)
		let min: Float = 70
		let max: Float = 150

		let minHueAngle: Float =  min / 360
		let maxHueAngle: Float = max / 360
		print("min:", min, "max:", max)
		
		let size = 64
		var cubeData = [Float](repeating: 0, count: size * size * size * 4)
		var rgb: [Float] = [0, 0, 0]
		var hsv: (h : Float, s : Float, v : Float)
		var offset = 0
		
		for z in 0 ..< size {
			rgb[2] = Float(z) / Float(size) // blue value
			for y in 0 ..< size {
				rgb[1] = Float(y) / Float(size) // green value
				for x in 0 ..< size {
					
					rgb[0] = Float(x) / Float(size) // red value
					hsv = RGBtoHSV(r: rgb[0], g: rgb[1], b: rgb[2])
					let alpha: Float = (hsv.h > minHueAngle && hsv.h < maxHueAngle) ? 0 : 1.0
					
					cubeData[offset] = rgb[0] * alpha
					cubeData[offset + 1] = rgb[1] * alpha
					cubeData[offset + 2] = rgb[2] * alpha
					cubeData[offset + 3] = alpha
					offset += 4
				}
			}
		}
		let b = cubeData.withUnsafeBufferPointer { Data(buffer: $0) }
		let data = b as NSData
		
		let colorCube = CIFilter(name: "CIColorCube", withInputParameters: [
			"inputCubeDimension": size,
			"inputCubeData": data
			])
		return colorCube!
	}

	
	
	func ciImagewith(_ name: String) -> CIImage {
		let url = Bundle.main.url(forResource: name, withExtension: "jpg")!
		let ciImage = CIImage(contentsOf: url)!
		return ciImage
	}
	
	
	@IBAction func filterButton(sender: UIButton) {
		chromaKeyFilter()
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}


}

