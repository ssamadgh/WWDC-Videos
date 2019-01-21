/*
See LICENSE folder for this sample’s licensing information.

Abstract:
This class demonstrates how to customize UISlider to make it more expressive in the context of a simple photo editing app
*/
import UIKit

class SliderCustomizationViewController: UIViewController {
    
    var originalImage = #imageLiteral(resourceName: "photo")
    var imageView = UIImageView()
    var tintSlider = UISlider()
    var temperatureSlider = UISlider()
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.1480545461, green: 0.1480545461, blue: 0.1480545461, alpha: 1)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "UIKit Customization"
        
        addSubviews()
    }
    
    override func viewDidLayoutSubviews() {
        customizeViews()
    }
    
    func trackImage(_ image: UIImage, width: CGFloat, resizingMode: UIImageResizingMode) -> UIImage {
        let capInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        let bounds = CGRect(x: 0, y: 0, width: width, height: image.size.height)
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { _ in
            image.resizableImage(withCapInsets: capInsets, resizingMode: .stretch).draw(in: bounds)
        }.resizableImage(withCapInsets: capInsets, resizingMode: resizingMode)
    }
    
    func addSubviews() {
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.image = originalImage
        
        view.addSubview(imageView)
        view.addSubview(tintSlider)
        view.addSubview(temperatureSlider)
        
        tintSlider.translatesAutoresizingMaskIntoConstraints = false
        temperatureSlider.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        let views: [String: UIView] = [ "tint": tintSlider, "temperature": temperatureSlider, "image": imageView ]
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[image]|", options: [], metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-[tint]-|", options: [], metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-[temperature]-|", options: [], metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[image]-[temperature(==32)]-[tint(==32)]-(8)-|",
                                                           options: [], metrics: nil, views: views))
        
        temperatureSlider.minimumValue = 2000
        temperatureSlider.maximumValue = 10_000
        temperatureSlider.value = 6500
        
        tintSlider.minimumValue = -100
        tintSlider.maximumValue = 100
        tintSlider.value = 0
    }
    
    func customizeViews() {
        tintSlider.minimumTrackTintColor = #colorLiteral(red: 0.262745098, green: 0.9607843137, blue: 0.0431372549, alpha: 1)
        tintSlider.maximumTrackTintColor = #colorLiteral(red: 0.9215686275, green: 0.2901960784, blue: 0.8196078431, alpha: 1)
        temperatureSlider.minimumTrackTintColor = #colorLiteral(red: 0.1333333333, green: 0.5647058824, blue: 0.8823529412, alpha: 1)
        temperatureSlider.maximumTrackTintColor = #colorLiteral(red: 0.9568627451, green: 0.4784313725, blue: 0.2156862745, alpha: 1)
        
        let tintMinTrackImage = trackImage(#imageLiteral(resourceName: "tint-track"), width: tintSlider.bounds.width, resizingMode: .tile)
        let tintMaxTrackImage = trackImage(#imageLiteral(resourceName: "tint-track"), width: tintSlider.bounds.width, resizingMode: .stretch)
        let temperatureMinTrackImage = trackImage(#imageLiteral(resourceName: "temperature-track"), width: temperatureSlider.bounds.width, resizingMode: .tile)
        let temperatureMaxTrackImage = trackImage(#imageLiteral(resourceName: "temperature-track"), width: temperatureSlider.bounds.width, resizingMode: .stretch)
        tintSlider.setMinimumTrackImage(tintMinTrackImage, for: .normal)
        tintSlider.setMaximumTrackImage(tintMaxTrackImage, for: .normal)
        temperatureSlider.setMinimumTrackImage(temperatureMinTrackImage, for: .normal)
        temperatureSlider.setMaximumTrackImage(temperatureMaxTrackImage, for: .normal)
    }
}
