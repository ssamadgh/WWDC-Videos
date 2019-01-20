//
//  InterfaceManager.swift
//  Running with a Snap
//
//  Created by Seyed Samad Gholamzadeh on 7/9/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

class InterfaceManager: NSObject {
	private var _blurredBackgroundImage: UIImage!
	private var _backgroundImage: UIImage!
	
	var backgroundImage: UIImage? {
		get {
			if self._backgroundImage == nil {
				let image = UIImage(contentsOfFile: InterfaceManager.rootInterfacePath.appendingPathComponent("backgroundImage.jpg").path)
				self._backgroundImage = image
			}
			return self._backgroundImage
		}
		
		set {
			DispatchQueue.global().async {
				var destRect = CGRect.zero
				destRect.size = UIScreen.main.bounds.size
				UIGraphicsBeginImageContextWithOptions(destRect.size, false, UIScreen.main.scale)
				newValue?.draw(in: destRect)
				let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
				UIGraphicsEndImageContext()
				
				self._backgroundImage = scaledImage
				self.write(self._backgroundImage, toFilename: "backgroundImage.jpg")
				self._blurredBackgroundImage = scaledImage?.applyLightEffect()
				self.write(self._blurredBackgroundImage, toFilename: "blurredBackgroundImage.jpg")

			}
		}
	}
	
	var blurredBackgroundImage: UIImage? {
		if self._blurredBackgroundImage == nil {
			self._blurredBackgroundImage = UIImage(contentsOfFile: InterfaceManager.rootInterfacePath.appendingPathComponent("blurredBackgroundImage.jpg").path)
		}
		if self._blurredBackgroundImage == nil {
			self._blurredBackgroundImage = self._backgroundImage?.applyLightEffect()
			self.write(self._blurredBackgroundImage, toFilename: "blurredBackgroundImage.jpg")
		}
		
		return self._blurredBackgroundImage
	}

	
	static var rootInterfacePath: URL = {
		let url = RunManager.rootDataPath.appendingPathComponent("interface")
		let fileManager = FileManager.default
		if !fileManager.fileExists(atPath: url.path) {
			try! fileManager.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
		}
		return url
	}()
	
	func write(_ image: UIImage?, toFilename fileName: String?) {
		guard image != nil, fileName != nil else { return }
		if let imageData = UIImageJPEGRepresentation(image!, 1.0) {
			try? imageData.write(to: InterfaceManager.rootInterfacePath.appendingPathComponent(fileName!), options: Data.WritingOptions.atomic)
		}
		
	}
	
	
}
