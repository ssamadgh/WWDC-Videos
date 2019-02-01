
import CoreImage
import Foundation


class JPTiltShiftGenerator: NSObject, CIFilterConstructor {
	
	@objc func filter(withName name: String) -> CIFilter? {
		return JPTiltShift()
	}
}

class JPTiltShift : CIFilter {

//	override var attributes: [String : Any] {
//		var costumAttr = super.attributes
////		costumAttr[kCIAttributeFilterDisplayName] = "Input Photo"
////		costumAttr[kCIAttributeFilterCategories] = [kCICategoryStillImage]
////		costumAttr[kCIAttributeFilterName] = "SourcePhotoFilter"
//		costumAttr[kCIInputImageKey] = [
//			kCIAttributeClass: "CIImage",
//			kCIAttributeDisplayName: "Image",
//			kCIAttributeType: kCIAttributeTypeImage]
//		print(costumAttr)
//		//		let costumeAttr: [String: Any] = [kCIAttributeFilterDisplayName : "Input Photo", kCIAttributeFilterCategories : [kCICategoryStillImage]]
//		return costumAttr
//	}

	
	class func register() {
		var attr: [String: Any] = [:]
		attr["inputImage"] = [
			kCIAttributeClass: "CIImage",
			kCIAttributeDisplayName: "Image",
			kCIAttributeType: kCIAttributeTypeImage]

        CIFilter.registerName("JPTiltShift", constructor: JPTiltShiftGenerator(), classAttributes: attr)
    }
	
    @objc dynamic var inputImage: CIImage?
    var inputRadius: CGFloat = 10
    var inputTop: CGFloat = 0.5
    var inputCenter: CGFloat = 0.25
    var inputBottom: CGFloat = 0.75
    
    override func setDefaults() {
		self.inputRadius = 10
		self.inputTop = 0.5
		self.inputCenter = 0.25
		self.inputBottom = 0.75
		
    }
	
    override var outputImage:CIImage? {
    let cropRect = self.inputImage!.extent
    let height = cropRect.size.height
    
        var blur = CIFilter(name: "CIGaussianBlur",
            withInputParameters:["inputImage" : self.inputImage!,
                                "inputRadius":self.inputRadius])
        

    blur = CIFilter(name: "CICrop",
        withInputParameters:["inputImage" : blur!.outputImage!,
							 "inputRectangle":CIVector(cgRect: cropRect)])

     var topGradient = CIFilter(name: "CILinearGradient",
        withInputParameters:["inputPoint0" : CIVector(x: 0, y: self.inputTop * height),
                            "inputColor0" : CIColor(red: 0, green: 1, blue: 0, alpha: 1),
                            "inputPoint1" : CIVector(x: 0, y: self.inputCenter * height),
                            "inputColor1" : CIColor(red: 0, green: 1, blue: 0, alpha: 0)
        ])

        
        var bottomGradient = CIFilter(name: "CILinearGradient",
            withInputParameters:["inputPoint0" : CIVector(x: 0, y: self.inputBottom * height),
                                "inputColor0" : CIColor(red: 0, green: 1, blue: 0, alpha: 1),
                                "inputPoint1" : CIVector(x: 0, y: self.inputCenter * height),
                                "inputColor1" : CIColor(red: 0, green: 1, blue: 0, alpha: 0)
            ])

        

        topGradient = CIFilter(name: "CICrop",
            withInputParameters:["inputImage" : topGradient!.outputImage!,
								 "inputRectangle":CIVector(cgRect: cropRect)
            ])

        bottomGradient = CIFilter(name: "CICrop",
            withInputParameters:["inputImage" : bottomGradient!.outputImage!,
								 "inputRectangle":CIVector(cgRect: cropRect)
            ])


    let gradients = CIFilter(name: "CIAdditionCompositing",
        withInputParameters: ["inputImage" : topGradient!.outputImage!,
                            "inputBackgroundImage" : bottomGradient!.outputImage!
        ])

        let tiltShift = CIFilter(name: "CIBlendWithMask",
            withInputParameters: ["inputImage" : blur!.outputImage!,
                                 "inputBackgroundImage" : self.inputImage!,
                                 "inputMaskImage" :gradients!.outputImage!
            ])


    
    return tiltShift?.outputImage
    }
}


