//
//  Run.swift
//  Running with a Snap
//
//  Created by Seyed Samad Gholamzadeh on 7/9/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

enum RunPhotoType {
	case preview, original
}

class Run: NSObject, NSCoding {

	var photoCounter: Int = 0
	var whereIs: String!
	var whenIs: Date!
	var uuid: UUID!
	var photos: [String]!
	var imageObjects: [String: UIImage]!
	
	var identifier: String {
		return self.uuid.uuidString
	}
	
	override var description: String {
		let desc = "<\(type(of: self)) \(self)> [\(self.identifier)] - \"\(self.whereIs)\" on \(self.whenIs); \(self.numberOfPhotos) photos"
		return desc
	}

	static var previewPhotoSize: CGSize {
		return CGSize(width: 75, height: 138)
	}
	
	lazy var photoPath: URL? = {
		let photoPath = RunManager.photoSavePath.appendingPathComponent("\(self.uuid.uuidString)")
		let fileManager = FileManager.default
		if !fileManager.fileExists(atPath: photoPath.path) {
			do {
				try fileManager.createDirectory(at: photoPath, withIntermediateDirectories: true, attributes: nil)
				try fileManager.createDirectory(at: photoPath.appendingPathComponent("previews"), withIntermediateDirectories: true, attributes: nil)
				try fileManager.createDirectory(at: photoPath.appendingPathComponent("photos"), withIntermediateDirectories: true, attributes: nil)
			}
			catch {
			}
		}
		
		return photoPath
	}()
	
	var numberOfPhotos: Int {
		self.loadPhotos()
		return self.photos.count
	}
	
	
	override init() {
		super.init()
		
		self.uuid = UUID()
		self.imageObjects = [:]
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init()
		
		if let uuid = aDecoder.decodeObject(forKey: "kRun_UUID") as? UUID {
			self.uuid = uuid
		}
		
		if let whenIs = aDecoder.decodeObject(forKey: "kRun_When") as? Date {
			self.whenIs = whenIs
		}
		
		if let whereIs = aDecoder.decodeObject(forKey: "kRun_Where") as? String {
			self.whereIs = whereIs
		}
		self.imageObjects = [:]
	}
	
	func encode(with aCoder: NSCoder) {
		aCoder.encode(self.uuid, forKey: "kRun_UUID")
		aCoder.encode(self.whenIs, forKey: "kRun_When")
		aCoder.encode(self.whereIs, forKey: "kRun_Where")
	}
	
	func loadPhotos() {
		if self.photos == nil {
			let fileManager = FileManager.default
			self.photos = try! fileManager.contentsOfDirectory(atPath: self.photoPath!.appendingPathComponent("previews").path)
		}
	}

	func photo(at index: Int, of type: RunPhotoType) -> UIImage? {
		self.loadPhotos()
		var image: UIImage? = nil
		if index < self.photos.count {
			var photoName = self.photos[index]
			if type == .preview {
				image = self.imageObjects[photoName]
				if image == nil {
					let imagePath = self.photoPath?.appendingPathComponent("previews").appendingPathComponent(photoName)
					if let data = try? Data(contentsOf: imagePath!) {
						image = UIImage(data: data, scale: UIScreen.main.scale)
					}
					self.imageObjects[photoName] = image
				}
			}
			else {
				photoName = ((photoName as NSString).deletingPathExtension as NSString).appendingPathExtension("jpg")!
				let imagePath = self.photoPath?.appendingPathComponent("photos").appendingPathComponent(photoName)
				if let data = try? Data(contentsOf: imagePath!) {
					image = UIImage(data: data, scale: UIScreen.main.scale)
				}
				
			}
		}
		return image
	}
	
	func save(_ photoData: Data) throws {
		
		let originalImage = UIImage(data: photoData)
		var destRect = CGRect.zero
		destRect.size = Run.previewPhotoSize
		UIGraphicsBeginImageContextWithOptions(destRect.size, false, UIScreen.main.scale)
		originalImage?.draw(in: destRect)
		let scaledImage = UIGraphicsGetImageFromCurrentImageContext()!
		UIGraphicsEndImageContext()
		
		let pngData = UIImagePNGRepresentation(scaledImage)
		
		let savePNGPath = self.photoPath!.appendingPathComponent("/previews/\(self.photoCounter).png")
		try pngData?.write(to: savePNGPath, options: Data.WritingOptions.atomic)
		let saveJPGPath = self.photoPath!.appendingPathComponent("/photos/\(self.photoCounter).jpg")
		try photoData.write(to: saveJPGPath, options: Data.WritingOptions.atomic)
		self.photoCounter += 1
	}
	
	func deletePhoto(at index: Int) throws {
		let fileManager = FileManager()
		var photoName = self.photos[index]
		
		for parts in [ ["previews", "png"], ["photos", "jpg"]] {
			let subpath = parts[0]
			let pathExtension = parts[1]
			photoName = ((photoName as NSString).deletingPathExtension as NSString).appendingPathExtension(pathExtension)!
			let photoPath = ((self.photoPath!.path as NSString).appendingPathComponent(subpath) as NSString).appendingPathComponent(photoName)
			try fileManager.removeItem(atPath: photoPath)
		}
		
		var newPhotoList = self.photos
		newPhotoList?.remove(at: index)
		self.photos = newPhotoList
		
		self.imageObjects.removeValue(forKey: photoName)
	}
	
}
