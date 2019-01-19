//
//  IconDownloader.swift
//  LazyTable
//
//  Created by Seyed Samad Gholamzadeh on 6/26/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//
/*
Abstract: Helper object for managing the downloading of a particular app's icon.
As a delegate "NSURLConnectionDelegate" is downloads the app icon in the background if it does not
yet exist and works in conjunction with the RootViewController to manage which apps need their icon.

A simple BOOL tracks whether or not a download is already in progress to avoid redundant requests.
*/

import UIKit

protocol IconDownloaderDelegate {
	func appImageDidLoad(_ indexPath: IndexPath)
}

let kAppIconSize: CGFloat = 48
class IconDownloader: NSObject {

	var appRecord: AppRecord!
	var indexPathInTableView: IndexPath!
	var delegate: IconDownloaderDelegate!
//	var activeDownload: Data!
	var imageTask: URLSessionTask!
	
	func startDownload() {
//		self.activeDownload = Data()
		// alloc+init and start an NSURLConnection; release on completion/failure
		let task = URLSession.shared.dataTask(with: URLRequest(url: URL(string: appRecord.imageURLString)!)) { (data, responce, error) in
			if error == nil {
				// Set appIcon and clear temporary data/image
				guard data != nil,
					let image = UIImage(data: data!)
					else { return }
				
				// Set appIcon and clear temporary data/image
				if image.size.width != kAppIconSize || image.size.height != kAppIconSize {
					
					let itemSize = CGSize(width: kAppIconSize, height: kAppIconSize)
					
					UIGraphicsBeginImageContext(itemSize)
					let imageRect = CGRect(x: 0.0, y: 0.0, width: itemSize.width, height: itemSize.height)
					image.draw(in: imageRect)
					self.appRecord.appIcon = UIGraphicsGetImageFromCurrentImageContext()
					UIGraphicsEndImageContext()

				}
				else {
					self.appRecord.appIcon = image
				}
			}
			
			// call our delegate and tell it that our icon is ready for display
			DispatchQueue.main.async {
				self.delegate.appImageDidLoad(self.indexPathInTableView)
			}
		}
		
		self.imageTask = task
		task.resume()
	}
	
	func cancelDownload() {
		self.imageTask.cancel()
		self.imageTask = nil
	}
}
