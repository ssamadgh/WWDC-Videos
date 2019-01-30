//
//  ViewController.swift
//  AVFoundationTest1
//
//  Created by Seyed Samad Gholamzadeh on 11/5/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import AVFoundation
import UIKit

class ViewController: UIViewController {

	var player: AVPlayer!
	var playerItemContext = 0
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.

		self.prepareToStreamPlay()
//		self.prepareToLocalDatabasePlay()
		
	}
	
	
	func prepareToStreamPlay() {
		
		let url = URL(string: "http://h1.mer30download.com/animation/khareji/footbalistha/1/FootB1%20(16).mp4")!
		
//		let url = Bundle.main.url(forResource: "art", withExtension: "mp4")!

		
//		let playerItem = AVPlayerItem(url: url)

//		playerItem.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), options: NSKeyValueObservingOptions(), context: &self.playerItemContext)
//
//		// Associate the player item with the player
//		self.player = AVPlayer(playerItem: playerItem)

		let asset = AVAsset(url: url)

		let keys = ["tracks"]


		asset.loadValuesAsynchronously(forKeys: keys) {

			var error: NSErrorPointer

			let trackStatus = asset.statusOfValue(forKey: keys.first!, error: error)

			switch trackStatus {
			case AVKeyValueStatus.loaded:
				print("stream loaded video with duration \(asset.duration.seconds)")
				let playerItem = AVPlayerItem(asset: asset)

				playerItem.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), options: NSKeyValueObservingOptions(), context: &self.playerItemContext)

				// Associate the player item with the player
				self.player = AVPlayer(playerItem: playerItem)


			case AVKeyValueStatus.failed:
				print("stream failed")


			case AVKeyValueStatus.cancelled:
				print("stream cancelled")

			default:
				break
			}

		}
		
	}
	
	func prepareToLocalDatabasePlay() {
		let url = Bundle.main.url(forResource: "art", withExtension: "mp4")!
		// Create asset to be played
		let asset = AVAsset(url: url)
		
		let assetKeys = [
			"playable",
			"hasProtectedContent"
		]
		// Create a new AVPlayerItem with the asset and an
		// array of asset keys to be automatically loaded
		let playerItem = AVPlayerItem(asset: asset, automaticallyLoadedAssetKeys: assetKeys)
//		let playerItem = AVPlayerItem(url: URL(string: "http://h1.mer30download.com/animation/khareji/footbalistha/1/FootB1%20(7).mp4")!)
		// Register as an observer of the player item's status property
		playerItem.addObserver(self,
							   forKeyPath: #keyPath(AVPlayerItem.status),
							   options: [.old, .new],
							   context: &playerItemContext)
		
		// Associate the player item with the player
		player = AVPlayer(playerItem: playerItem)
	}
	
	
//	override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
//		if let item = object as? AVPlayerItem, item.status == .readyToPlay {
//			print(item.status.rawValue)
//
//		}
//	}

	override func observeValue(forKeyPath keyPath: String?,
							   of object: Any?,
							   change: [NSKeyValueChangeKey : Any]?,
							   context: UnsafeMutableRawPointer?) {
		// Only handle observations for the playerItemContext
		guard context == &playerItemContext else {
			super.observeValue(forKeyPath: keyPath,
							   of: object,
							   change: change,
							   context: context)
			return
		}
		
		if keyPath == #keyPath(AVPlayerItem.status) {
			let status: AVPlayerItem.Status
			
			// Get the status change from the change dictionary
			if let item = object as? AVPlayerItem {
				status = item.status
			} else {
				status = .unknown
			}
			
			// Switch over the status
			switch status {
			case .readyToPlay:
			// Player item is ready to play.
				print("Player item is ready to play.")
				let layer = AVPlayerLayer(player: player)
				let width = max(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
				let height = min(UIScreen.main.bounds.width, UIScreen.main.bounds.height)

				layer.frame = CGRect(x: 0, y: 0, width: width, height: height)
				self.view.layer.addSublayer(layer)
//				player.seek(to: CMTime(seconds: 927, preferredTimescale: player.currentItem!.asset.duration.timescale))
				player.play()

			case .failed:
			// Player item failed. See error.
				print("Player item failed. See error.")
			case .unknown:
				// Player item is not yet ready.
				print("Player item is not yet ready.")
			}
			
		}
	}

}

