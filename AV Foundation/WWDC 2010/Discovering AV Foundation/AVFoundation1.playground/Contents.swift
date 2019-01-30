/// AVFoundation

import AVFoundation
import UIKit
import PlaygroundSupport

let asset = AVURLAsset(url: Bundle.main.url(forResource: "art", withExtension: "mp4")!)

let keys = ["tracks"]


let playerItem = AVPlayerItem(asset: asset)
let player = AVPlayer(playerItem: playerItem)
//print(asset.tracks.map { $0.formatDescriptions })

let layer = AVPlayerLayer(player: player)

let frame = CGRect(x: 0, y: 0, width: 300, height: 200)

layer.frame = frame
let view = UIView(frame: frame)
//view.backgroundColor = .red
view.layer.addSublayer(layer)
PlaygroundPage.current.liveView = view
PlaygroundPage.current.needsIndefiniteExecution = true

//let animation = CABasicAnimation(keyPath: <#T##String?#>)

UIView.animate(withDuration: 5) {
//	view.transform = CGAffineTransform(a: 1, b: 0, c: 0, d: 1, tx: 30, ty: 0)
//	view.transform = view.transform.concatenating(CGAffineTransform(scaleX: 0.5, y: 0.5))
	var transform3d = CATransform3DIdentity

	//Add the perspective!!!
	transform3d.m34 = 1.0 / -500
	transform3d = CATransform3DRotate(transform3d, 45.0 * CGFloat.pi / 180.0, 0, 1, 0);
	view.layer.transform = transform3d
}

player.play()


func getVideoThumbnail(from asset: AVAsset) -> UIImage? {
	let assetImageGenerator = AVAssetImageGenerator(asset: asset)
	assetImageGenerator.appliesPreferredTrackTransform = true
	var time = asset.duration
	time.value
	time.value = (0...time.value).randomElement()!
	
	do {
		let imageRef = try assetImageGenerator.copyCGImage(at: time, actualTime: nil)
		return UIImage(cgImage: imageRef)
	} catch {
		print(error.localizedDescription)
		return nil
	}
	
}

let streamAsset = AVAsset(url: URL(string: "http://h1.mer30download.com/animation/khareji/footbalistha/1/FootB1%20(7).mp4")!)
let streamKeys = ["tracks"]

streamAsset.loadValuesAsynchronously(forKeys: streamKeys) {
	
	var error: NSErrorPointer
	
	let trackStatus = streamAsset.statusOfValue(forKey: streamKeys.first!, error: error)
	
	switch trackStatus {
	case AVKeyValueStatus.loaded:
		print("stream loaded")

		streamAsset.duration.seconds
		let thumbnail = getVideoThumbnail(from: streamAsset)
		

	case AVKeyValueStatus.failed:
		print("stream failed")
		break
		
	case AVKeyValueStatus.cancelled:
		print("stream cancelled")

		break
		
	default:
		break
	}
	
}


