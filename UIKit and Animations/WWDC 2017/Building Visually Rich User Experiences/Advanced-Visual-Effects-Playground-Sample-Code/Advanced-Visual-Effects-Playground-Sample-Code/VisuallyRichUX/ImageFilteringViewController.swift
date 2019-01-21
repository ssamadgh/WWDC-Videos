/*
See LICENSE folder for this sample’s licensing information.

Abstract:
This class illustrates how to use Core Image to filter an image and display the resulting image with UIKit.
*/
import UIKit

class ImageFilteringViewController: SliderCustomizationViewController {
    
    let ciContext = CIContext()
    let imageProcessingQueue = DispatchQueue(label: "com.apple.visual-effects.image-processing")
    var jobIndex = UInt64(0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Core Image Filters"
        
        addSubviews()
        
        temperatureSlider.addTarget(self, action: #selector(temperatureDidChange), for: .valueChanged)
        tintSlider.addTarget(self, action: #selector(tintDidChange), for: .valueChanged)
    }
    
    @objc
    func temperatureDidChange(_ sender: Any?) {
        updateFilteredImage()
    }
    
    @objc
    func tintDidChange(_ sender: Any?) {
        updateFilteredImage()
    }
    
    func updateFilteredImage() {
        guard let originalCGImage = originalImage.cgImage else { return }
        
        let originalCIImage = CIImage(cgImage: originalCGImage)
        
        let neutralTemperature = CGFloat(temperatureSlider.value)
        let neutralTint = CGFloat(tintSlider.value)
        let neutral = CIVector(x: neutralTemperature, y: neutralTint)
        
        let targetNeutralTemperature = CGFloat(6500)
        let targetNeutralTint = CGFloat(0)
        let targetNeutral = CIVector(x: targetNeutralTemperature, y: targetNeutralTint)
        
        let parameters = [ "inputImage": originalCIImage,
                           "inputNeutral": neutral,
                           "inputTargetNeutral": targetNeutral ]
        
        guard let filter = CIFilter(name: "CITemperatureAndTint", withInputParameters: parameters) else { return }
        
        jobIndex += 1
        let myJobIndex = jobIndex
        if let filteredImage = filter.outputImage {
            imageProcessingQueue.async {
                if self.jobIndex != myJobIndex { return }
                if let filteredCGImage = self.ciContext.createCGImage(filteredImage, from: filteredImage.extent) {
                    DispatchQueue.main.async {
                        self.imageView.image = UIImage(cgImage: filteredCGImage)
                    }
                }
            }
        }
    }
}
