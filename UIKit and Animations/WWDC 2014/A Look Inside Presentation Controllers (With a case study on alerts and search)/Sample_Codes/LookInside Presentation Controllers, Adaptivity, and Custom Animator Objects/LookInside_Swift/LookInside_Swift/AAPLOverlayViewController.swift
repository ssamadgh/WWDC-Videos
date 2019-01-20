//
//  AAPLOverlayViewController.swift
//  LookInside_Swift
//
//  Created by Seyed Samad Gholamzadeh on 7/18/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

class AAPLOverlayViewController: UIViewController {

	var backgroundView: UIVisualEffectView!
	var foregroundContentView: UIVisualEffectView!
	
	var blurEffect: UIBlurEffect!
	var imageView: UIImageView!
	
	var hueLabel: AAPLOverlayVibrantLabel!
	var hueSlider: UISlider!
	
	var saturationLabel: AAPLOverlayVibrantLabel!
	var saturationSlider: UISlider!

	var brightnessLabel: AAPLOverlayVibrantLabel!
	var brightnessSlider: UISlider!

	var saveButton: UIButton!
	var currentPhotoView: AAPLPhotoCollectionViewCell!
	
	var photoView: AAPLPhotoCollectionViewCell! {
		didSet {
			if self.currentPhotoView != photoView {
				self.currentPhotoView = photoView
			}
			self.configureCIObjects()
		}
	}

	var context: CIContext!
	var baseCIImage: CIImage!
	var colorControlsFilter: CIFilter!
	var hueAdjustFilter: CIFilter!

	var processingQueue: DispatchQueue!
	
	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		
		self.modalPresentationStyle = .custom
		self.setup()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.foregroundContentView = UIVisualEffectView(effect: UIVibrancyEffect(blurEffect: self.blurEffect))
		self.backgroundView = UIVisualEffectView(effect: self.blurEffect)
		self.configureViews()
    }
	
	func configureCIObjects() {
		if self.context == nil {
			self.context = CIContext(options: nil)
		}
		
		self.baseCIImage = CIImage(cgImage: self.photoView.image!.cgImage!)
	}
	
	@objc func sliderChanged(_ sender: Any?) {
		
		let hue: CGFloat = CGFloat(self.hueSlider.value)
		let saturation: CGFloat = CGFloat(self.saturationSlider.value)
		let brightness: CGFloat = CGFloat(self.brightnessSlider.value)
		
		// Update labels
		
		self.hueLabel.text = NSLocalizedString("Hue: \(hue)", comment: "Hue label format.")
		self.saturationLabel.text = NSLocalizedString("Saturation: \(saturation)", comment: "Saturation label format.")
		self.brightnessLabel.text = NSLocalizedString("Brightness: \(brightness)", comment: "Brightness label format.")

		// Apply effects to image
		let imageSize = self.photoView.image!.size
		self.processingQueue.async {
			if self.colorControlsFilter == nil {
				self.colorControlsFilter = CIFilter(name: "CIColorControls")
			}
			
			self.colorControlsFilter.setValue(self.baseCIImage, forKey: kCIInputImageKey)
			self.colorControlsFilter.setValue(saturation, forKey: "inputSaturation")
			self.colorControlsFilter.setValue(brightness, forKey: "inputBrightness")

			var coreImageOutputImage = self.colorControlsFilter.outputImage
			
			if self.hueAdjustFilter == nil {
				self.hueAdjustFilter = CIFilter(name: "CIHueAdjust")
			}
			self.hueAdjustFilter.setValue(coreImageOutputImage, forKey: kCIInputImageKey)
			self.hueAdjustFilter.setValue(hue, forKey: "inputAngle")
			
			coreImageOutputImage = self.hueAdjustFilter.outputImage
			
			let cgImage = self.context.createCGImage(coreImageOutputImage!, from: CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height))
			let image = UIImage(cgImage: cgImage!)
			
			DispatchQueue.main.async {
				self.imageView.image = image
			}
		}
	}
	
	@objc func savePushed(_ sender: Any) {
		self.photoView.image = self.imageView.image
		self.presentingViewController?.dismiss(animated: true, completion: nil)
	}
	
	func configuredOverlaySlider() -> UISlider {
		let slider = UISlider()
		slider.translatesAutoresizingMaskIntoConstraints = false
		slider.addTarget(self, action: #selector(sliderChanged(_:)), for: .valueChanged)
		slider.isContinuous = false
		return slider
	}

	func setup() {
		self.imageView = UIImageView()
		self.imageView.contentMode = .scaleAspectFit
		self.imageView.translatesAutoresizingMaskIntoConstraints = false
		self.blurEffect = UIBlurEffect(style: .extraLight)
		
		self.processingQueue = DispatchQueue(label: "image processing queue")
	}
	
	func configureViews() {
		self.imageView.image = self.photoView.image
		self.view.backgroundColor = .clear
		
		self.backgroundView.translatesAutoresizingMaskIntoConstraints = false
		self.foregroundContentView.translatesAutoresizingMaskIntoConstraints = false
		
		self.hueLabel = AAPLOverlayVibrantLabel()
		self.hueSlider = self.configuredOverlaySlider()
		self.hueSlider.maximumValue = 10.0
		
		self.saturationLabel = AAPLOverlayVibrantLabel()
		self.saturationSlider = self.configuredOverlaySlider()
		self.saturationSlider.value = 1.0
		self.saturationSlider.maximumValue = 2.0

		self.brightnessLabel = AAPLOverlayVibrantLabel()
		self.brightnessSlider = self.configuredOverlaySlider()
		self.brightnessSlider.minimumValue = -0.5
		self.brightnessSlider.maximumValue = 0.5
		
		self.saveButton = UIButton(type: .system)
		self.saveButton.translatesAutoresizingMaskIntoConstraints = false
		self.saveButton.setTitle(NSLocalizedString("Save", comment: "Save button title."), for: .normal)
		self.saveButton.titleLabel?.font = UIFont.systemFont(ofSize: 32.0)
		self.saveButton.addTarget(self, action: #selector(savePushed(_:)), for: .touchUpInside)
		
		self.view.addSubview(self.backgroundView)
		self.view.addSubview(self.foregroundContentView)

		self.foregroundContentView.contentView.addSubview(self.hueLabel)
		self.foregroundContentView.contentView.addSubview(self.hueSlider)

		self.foregroundContentView.contentView.addSubview(self.saturationLabel)
		self.foregroundContentView.contentView.addSubview(self.saturationSlider)

		self.foregroundContentView.contentView.addSubview(self.brightnessLabel)
		self.foregroundContentView.contentView.addSubview(self.brightnessSlider)

		self.foregroundContentView.contentView.addSubview(self.saveButton)

		self.view.addSubview(self.imageView)
		
		// add constraints
		let views = ["backgroundView" : backgroundView, "foregroundContentView" : foregroundContentView, "hueLabel" : hueLabel, "hueSlider" : hueSlider, "saturationLabel" : saturationLabel, "saturationSlider" : saturationSlider, "brightnessLabel" : brightnessLabel, "brightnessSlider" : brightnessSlider, "saveButton" : saveButton, "imageView" : imageView] as [String : Any]
		
		self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[backgroundView]|", options: NSLayoutFormatOptions(), metrics: nil, views: views))
		self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[backgroundView]|", options: NSLayoutFormatOptions(), metrics: nil, views: views))

		self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[foregroundContentView]|", options: NSLayoutFormatOptions(), metrics: nil, views: views))
		self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[foregroundContentView]|", options: NSLayoutFormatOptions(), metrics: nil, views: views))

		self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[hueLabel]-|", options: NSLayoutFormatOptions(), metrics: nil, views: views))
		self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[hueSlider]-|", options: NSLayoutFormatOptions(), metrics: nil, views: views))
		self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[saturationLabel]-|", options: NSLayoutFormatOptions(), metrics: nil, views: views))
		self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[saturationSlider]-|", options: NSLayoutFormatOptions(), metrics: nil, views: views))
		self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[brightnessLabel]-|", options: NSLayoutFormatOptions(), metrics: nil, views: views))
		self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[brightnessSlider]-|", options: NSLayoutFormatOptions(), metrics: nil, views: views))
		self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[saveButton]-|", options: NSLayoutFormatOptions(), metrics: nil, views: views))
		self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[imageView]|", options: NSLayoutFormatOptions(), metrics: nil, views: views))
		
		self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(>=30)-[hueLabel]-[hueSlider]-[saturationLabel]-[saturationSlider]-[brightnessLabel]-[brightnessSlider]-[saveButton]-(>=10)-[imageView]|", options: NSLayoutFormatOptions(), metrics: nil, views: views))

		self.sliderChanged(nil)
	}
	
}

class AAPLOverlayVibrantLabel: UILabel {
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.translatesAutoresizingMaskIntoConstraints = false
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func tintColorDidChange() {
		self.textColor = self.tintColor
	}
}
