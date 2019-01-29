//
//  ViewController.swift
//  CIFunHouseSwift
//
//  Created by Seyed Samad Gholamzadeh on 8/7/1396 AP.
//  Copyright © 1396 AP Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit
import AVFoundation
import GLKit

//import CoreText
//import AssetsLibrary
//import ImageIO


let kUserDefaultsKey = "FilterSettings"
let FHViewControllerDidStartCaptureSessionNotification = "FHViewControllerDidStartCaptureSessionNotification"
let kTempVideoFilename = "recording.mov"
let kFPSLabelUpdateInterval: TimeInterval = 0.25
var sDeviceRgbColorSpace: CGColorSpace? = nil

func FCGetTransformForDeviceOrientation(_ orientation: UIDeviceOrientation, mirrored: Bool) -> CGAffineTransform {
	// Internal comment: This routine assumes that the native camera image is always coming from a UIDeviceOrientationLandscapeLeft (i.e. the home button is on the RIGHT, which equals AVCaptureVideoOrientationLandscapeRight!), although in the future this assumption may not hold; better to get video output's capture connection's videoOrientation property, and apply the transform according to the native video orientation
	
	// Also, it may be desirable to apply the flipping as a separate step after we get the rotation transform
	
	let result: CGAffineTransform
	
	switch (orientation) {
		
	case .portrait, .faceUp, .faceDown:
		result = CGAffineTransform(rotationAngle: .pi/2)

	case .portraitUpsideDown:
		result = CGAffineTransform(rotationAngle: 3*(.pi)/2)

	case .landscapeLeft:
		result = mirrored ?  CGAffineTransform(rotationAngle: .pi) : CGAffineTransform.identity

	default:
		result = mirrored ? CGAffineTransform.identity : CGAffineTransform(rotationAngle: .pi)
	}
	
	return result
}

// an inline function to filter a CIImage through a filter chain; note that each image input attribute may have different source
func runFilter(cameraImage: CIImage, filters: [CIFilter]) -> CIImage? {
	var currentImage: CIImage? = nil
	var activeInputs: [CIImage] = []
	
	for filter in filters {
		if filter is SourceVideoFilter {
			filter.setValue(cameraImage, forKey: kCIInputImageKey)
		}
		else if filter is SourcePhotoFilter {
			// nothing to do here
		}
		else {
			for attrName in filter.imageInputAttributeKeys {
				if let top = activeInputs.last {
					filter.setValue(top, forKey: attrName)
					activeInputs.removeLast()
				}
				else {
					print("failed to set \(attrName) for \(filter.name)")
				}
			}
		}
		
		currentImage = filter.outputImage
		
		if currentImage == nil { return nil}
		
		activeInputs.append(currentImage!)
	}
	
	if let extent = currentImage?.extent, extent.isEmpty {
		return nil
	}
	
	return currentImage
}


//MARK: - FHViewController
class FHViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate, FilterListControllerDelegate, SettingsControllerDelegate, UIPopoverPresentationControllerDelegate {

	@IBOutlet weak var toolbar: UIToolbar!
	@IBOutlet weak var recordStopButton: UIBarButtonItem!
	@IBOutlet weak var fpsLabel: UIBarButtonItem!
	@IBOutlet weak var settingsButton: UIBarButtonItem!
	@IBOutlet weak var filtersButton: UIBarButtonItem!

	var filterListPopoverController: UIPopoverPresentationController!
	var filterListNavigationController: UINavigationController!
	
	var settingsPopoverController: UIPopoverPresentationController!
	var settingsNavigationController: UINavigationController!

	private var videoPreviewView: GLKView?
	private var window: UIView!
	private var ciContext: CIContext!
	private var eagleContext: EAGLContext!
	private var videoPreviewViewBounds: CGRect!
	
	private var audioDevice: AVCaptureDevice!
	private var videoDevice: AVCaptureDevice!
	private var captureSession: AVCaptureSession!
	
	private var assetWriter: AVAssetWriter!
	private var assetWriterAudioInput: AVAssetWriterInput!
	private var assetWriterVideoInput: AVAssetWriterInput!
	private var assetWriterInputPixelBufferAdaptor: AVAssetWriterInputPixelBufferAdaptor!
	
	private var captureSessionQueue: DispatchQueue!
	private var backgroundRecordingID: UIBackgroundTaskIdentifier!
	
	private var videoWritingStarted: Bool!
	private var videoWrtingStartTime: CMTime!
	private var currentAudioSampleBufferFormatDescription: CMFormatDescription!
	private var currentVideoDimensions: CMVideoDimensions!
	private var currentVideoTime: CMTime!
	
	private var labelUpdateTimer: Timer!
	
	private var filterPopoverVisibleBeforeRotation: Bool!
	private var settingsPopoverVisibleBeforeRotation: Bool!

	
	
	private var filterStack: FilterStack
	private var activeFilters: [CIFilter]
	private var frameRateCalculator: FrameRateCalculator

	override var shouldAutorotate: Bool {
		return true
	}
	
	required init?(coder aDecoder: NSCoder) {
		
		
		// create the shared color space object once
		
		DispatchQueue.global().async {
			sDeviceRgbColorSpace = CGColorSpaceCreateDeviceRGB()
		}
		
		// load the filters and their configurations
		self.filterStack = FilterStack()
		self.activeFilters = filterStack.activeFilters
		self.frameRateCalculator = FrameRateCalculator()
		
		// create the dispatch queue for handling capture session delegate method calls
		self.captureSessionQueue = DispatchQueue(label: "capture_session_queue")
		
		super.init(coder: aDecoder)

		UIApplication.shared.isStatusBarHidden = true
	}
	
	
	//MARK: - Views Life Cycle
	
	override func viewDidLoad() {
		super.viewDidLoad()

		let filterListController = FilterListController(style: .plain)
		filterListController.filterStack = self.filterStack
		filterListController.delegate = self
		filterListController.preferredContentSize = CGSize(width: 320.0, height: 480.0)
		
		self.filterListNavigationController = UINavigationController(rootViewController: filterListController)
		self.filterListNavigationController.modalPresentationStyle = .popover

		
		let settingsController = SettingsController(style: .grouped)
		settingsController.delegate = self
		settingsController.preferredContentSize = CGSize(width: 320.0, height: 480.0)
		
		self.settingsNavigationController = UINavigationController(rootViewController: settingsController)
		self.settingsNavigationController.modalPresentationStyle = .popover
		
		
		// remove the view's background color; this allows us not to use the opaque property (self.view.opaque = NO) since we remove the background color drawing altogether
		self.view.backgroundColor = nil
		
		// setup the GLKView for video/image preview
		self.window = (UIApplication.shared.delegate as! AppDelegate).window! as UIView
		self.eagleContext = EAGLContext(api: EAGLRenderingAPI.openGLES2)
		self.videoPreviewView = GLKView(frame: window.bounds, context: eagleContext)
		self.videoPreviewView?.enableSetNeedsDisplay = true
		
		// because the native video image from the back camera is in UIDeviceOrientationLandscapeLeft (i.e. the home button is on the right), we need to apply a clockwise 90 degree transform so that we can draw the video preview as if we were in a landscape-oriented view; if you're using the front camera and you want to have a mirrored preview (so that the user is seeing themselves in the mirror), you need to apply an additional horizontal flip (by concatenating CGAffineTransformMakeScale(-1.0, 1.0) to the rotation transform)
		videoPreviewView?.transform = CGAffineTransform(rotationAngle: .pi/2)
		
		videoPreviewView?.frame = window.bounds
		
		// we make our video preview view a subview of the window, and send it to the back; this makes FHViewController's view (and its UI elements) on top of the video preview, and also makes video preview unaffected by device rotation
		if self.videoPreviewView != nil {
			window.addSubview(videoPreviewView!)
			window.sendSubview(toBack: videoPreviewView!)
//			self.layout(videoPreviewView!, to: window)
		}

		
		// create the CIContext instance, note that this must be done after _videoPreviewView is properly set up
		self.ciContext = CIContext(eaglContext: self.eagleContext)
		
		// bind the frame buffer to get the frame buffer width and height;
		// the bounds used by CIContext when drawing to a GLKView are in pixels (not points),
		// hence the need to read from the frame buffer's width and height;
		// in addition, since we will be accessing the bounds in another queue (_captureSessionQueue),
		// we want to obtain this piece of information so that we won't be
		// accessing _videoPreviewView's properties from another thread/queue
		videoPreviewView?.bindDrawable()
		videoPreviewViewBounds = CGRect.zero
		
		if videoPreviewView != nil {
			videoPreviewViewBounds.size.width = CGFloat(videoPreviewView!.drawableWidth)
			videoPreviewViewBounds.size.height = CGFloat(videoPreviewView!.drawableHeight)
		}
		
		filterListController.screenSize = CGSize(width: videoPreviewViewBounds.size.width, height: videoPreviewViewBounds.size.height)
		
		NotificationCenter.default.addObserver(self, selector: #selector(handleAttributeValueUpdate(_:)), name: NSNotification.Name(FilterAttributeValueDidUpdateNotification), object: nil)
		
		NotificationCenter.default.addObserver(self, selector: #selector(handleFHFilterImageAttributeSourceChange(_:)), name: NSNotification.Name(kFHFilterImageAttributeSourceDidChangeNotification), object: nil)

		NotificationCenter.default.addObserver(self, selector: #selector(handleSettingUpdate(_:)), name: NSNotification.Name(kFHSettingDidUpdateNotification), object: nil)

		NotificationCenter.default.addObserver(self, selector: #selector(handleFilterStackActiveFilterListDidChangeNotification(_:)), name: NSNotification.Name(FilterStackActiveFilterListDidChangeNotification), object: nil)

		NotificationCenter.default.addObserver(self, selector: #selector(handleAVCaptureSessionWasInterruptedNotification(_:)), name: NSNotification.Name.AVCaptureSessionWasInterrupted, object: nil)

		NotificationCenter.default.addObserver(self, selector: #selector(handleUIApplicationDidEnterBackgroundNotification(_:)), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
		
		NotificationCenter.default.addObserver(self, selector: #selector(handleRotation), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
		
		// check the availability of video and audio devices
		// create and start the capture session only if the devices are present

		// populate the defaults
		FCPopulateDefaultSettings()
		
		// see if we have any video device
		if AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInTelephotoCamera, .builtInDualCamera, .builtInWideAngleCamera, .builtInMicrophone], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.unspecified).devices.count > 0 {
			let audioDevices = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInMicrophone], mediaType: AVMediaType.audio, position: AVCaptureDevice.Position.unspecified).devices
			if !audioDevices.isEmpty {
				self.audioDevice = audioDevices.first!	// use the first audio device
			}
			self.start()
		}
//		self.start()

		self.toolbar.isTranslucent = false
		self.fpsLabel.title = ""
		self.fpsLabel.isEnabled = false
		self.recordStopButton.isEnabled = false
	}
	
	func layout(_ view: UIView, to parentView: UIView) {
		view.translatesAutoresizingMaskIntoConstraints = false
		view.leadingAnchor.constraint(equalTo: parentView.leadingAnchor, constant: 0).isActive = true
		view.trailingAnchor.constraint(equalTo: parentView.trailingAnchor, constant: 0).isActive = true
		view.topAnchor.constraint(equalTo: parentView.topAnchor, constant: 0).isActive = true
		view.bottomAnchor.constraint(equalTo: parentView.bottomAnchor, constant: 0).isActive = true
	}

	
	deinit {
		// remove the videoPreviewView
		videoPreviewView?.removeFromSuperview()
		videoPreviewView = nil
		
		self.stopWriting()
		self.stop()
		
		NotificationCenter.default.removeObserver(self, name: NSNotification.Name(FilterAttributeValueDidUpdateNotification), object: nil)
		NotificationCenter.default.removeObserver(self, name: NSNotification.Name(kFHFilterImageAttributeSourceDidChangeNotification), object: nil)
		NotificationCenter.default.removeObserver(self, name: NSNotification.Name(kFHSettingDidUpdateNotification), object: nil)
		NotificationCenter.default.removeObserver(self, name: NSNotification.Name(FilterStackActiveFilterListDidChangeNotification), object: nil)
		NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVCaptureSessionWasInterrupted, object: nil)
		NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
	}

	
	//MARK: - Actions
	
	@IBAction func recordStopAction(_ sender: UIBarButtonItem) {
		if assetWriter != nil {
			self.stopWriting()
		}
		else {
			self.startWriting()
		}
	}

	@IBAction func filtersAction(_ sender: UIBarButtonItem) {
		
		// set the global crop max
		if currentVideoDimensions != nil {
			FCSetGlobalCropFilterMaxValue(CGFloat(max(currentVideoDimensions.width, currentVideoDimensions.height)))
		}
		
		if UIDevice.current.userInterfaceIdiom == .phone {
			UIApplication.shared.isStatusBarHidden = false
			self.present(self.filterListNavigationController, animated: true, completion: nil)
		}
		else {
			
			if self.settingsNavigationController.presentedViewController != nil {
				self.settingsNavigationController.dismiss(animated: true, completion: nil)
			}
			
			if self.filterListNavigationController.presentedViewController != nil {
				self.filterListNavigationController.dismiss(animated: true, completion: nil)
			}
			else {
				self.filterListPopoverController = self.filterListNavigationController.popoverPresentationController
				self.filterListPopoverController.barButtonItem = sender
				self.present(self.filterListNavigationController, animated: true, completion: nil)
			}
		}
	}

	@IBAction func settingsAction(_ sender: UIBarButtonItem) {
		
		if UIDevice.current.userInterfaceIdiom == .phone {
			UIApplication.shared.isStatusBarHidden = false
			self.present(self.settingsNavigationController, animated: true, completion: nil)
		}
		else {
			if self.filterListNavigationController.presentedViewController != nil {
				self.filterListNavigationController.dismiss(animated: true, completion: nil)
			}
			
			if self.settingsNavigationController.presentedViewController != nil {
				self.settingsNavigationController.dismiss(animated: true, completion: nil)
			}
			else {
				self.settingsPopoverController = self.settingsNavigationController.popoverPresentationController!
				self.settingsPopoverController.delegate = self
				self.settingsPopoverController.barButtonItem = sender
				self.present(self.settingsNavigationController, animated: true, completion: nil)
			}
			
		}
	}
	
	func start() {
		
		if captureSession != nil {
			return
		}
		
		self.stopLabelUpdateTimer()
		
		captureSessionQueue.async {
			
			// get the input device and also validate the settings
			let videoDevices = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.unspecified).devices
			
			let position: AVCaptureDevice.Position = AVCaptureDevice.Position(rawValue: UserDefaults.standard.integer(forKey: kFHSettingCameraPositionKey))!
			
			self.videoDevice = nil
			
			for device in videoDevices {
				if device.position == position {
					self.videoDevice = device
					break
				}
			}
			
			if self.videoDevice == nil {
				self.videoDevice = videoDevices.first!
				UserDefaults.standard.set(self.videoDevice.position, forKey: kFHSettingCameraPositionKey)
			}
			
			// obtain device input
			let videoDeviceInput: AVCaptureDeviceInput
			do {
				videoDeviceInput = try AVCaptureDeviceInput(device: self.videoDevice)
				

			} catch {
				self.showAlertWith(message: "Unable to obtain video device input, error: \(error)")
				return
			}
			
			let audioDeviceInput: AVCaptureDeviceInput
			
			do {
				audioDeviceInput = try AVCaptureDeviceInput(device: self.audioDevice)
			}
			catch {
				self.showAlertWith(message: "Unable to obtain audio device input, error: \(error)")
				return
			}
			
			// obtain the preset and validate the preset
			var preset: AVCaptureSession.Preset = AVCaptureSession.Preset(rawValue: UserDefaults.standard.object(forKey: kFHSettingCaptureSessionPresetKey) as! String)
			
			if !self.videoDevice.supportsSessionPreset(preset) {
				preset = AVCaptureSession.Preset.medium
				UserDefaults.standard.set(preset, forKey: kFHSettingCaptureSessionPresetKey)
			}
			
			if !self.videoDevice.supportsSessionPreset(preset) {
				self.showAlertWith(message: "Capture session preset not supported by video device: \(preset)")
				return
			}
			
			// CoreImage wants BGRA pixel format
			let outputSettings: [String : Any] = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
			
			// create the capture session
			self.captureSession = AVCaptureSession()
			self.captureSession.sessionPreset = preset
			
			// create and configure video data output
			let videoDataOutput = AVCaptureVideoDataOutput()
			videoDataOutput.videoSettings = outputSettings
			videoDataOutput.alwaysDiscardsLateVideoFrames = true
			videoDataOutput.setSampleBufferDelegate(self, queue: self.captureSessionQueue)
			
			// configure audio data output
			var audioDataOutput: AVCaptureAudioDataOutput? = nil
			
			if self.audioDevice != nil {
				audioDataOutput = AVCaptureAudioDataOutput()
				audioDataOutput?.setSampleBufferDelegate(self, queue: self.captureSessionQueue)
			}
			
			// begin configure capture session
			self.captureSession.beginConfiguration()
			
			if !self.captureSession.canAddOutput(videoDataOutput) {
				self.showAlertWith(message: "Cannot add video data output")
				self.captureSession = nil
				return
			}
			
			if audioDataOutput != nil {
				if !self.captureSession.canAddOutput(audioDataOutput!) {
					self.showAlertWith(message: "Cannot add still audio data output")
					self.captureSession = nil
					return
				}
			}
			
			// connect the video device input and video data and still image outputs
			self.captureSession.addInput(videoDeviceInput)
			self.captureSession.addOutput(videoDataOutput)
			
			if self.audioDevice != nil {
				self.captureSession.addInput(audioDeviceInput)
				self.captureSession.addOutput(audioDataOutput!)
			}
			
			self.captureSession.commitConfiguration()
			
			// then start everything
			self.frameRateCalculator.reset()
			self.captureSession.startRunning()
			
			DispatchQueue.main.async {
				self.startLabelUpdateTimer()
				
				let window: UIView = (UIApplication.shared.delegate as! AppDelegate).window!
				
				var transform = CGAffineTransform(rotationAngle: .pi/2)
				
				// apply the horizontal flip
				let shouldMirror = AVCaptureDevice.Position.front == self.videoDevice.position
				
				if shouldMirror {
					transform = transform.concatenating(CGAffineTransform(scaleX: -1.0, y: 1.0))
				}
				
				self.videoPreviewView?.transform = transform
				self.videoPreviewView?.frame = window.bounds

				NotificationCenter.default.post(name: NSNotification.Name(FHViewControllerDidStartCaptureSessionNotification), object: self)
			}
			
		}
	}
	
	func stop() {
		
		guard self.captureSession != nil else {
			return
		}
		
		guard self.captureSession.isRunning else {
			return
		}

		self.captureSession.stopRunning()
		
		self.captureSessionQueue.async {
			print("waiting for capture session to end")
		}
		
		self.stopWriting()
		
		self.captureSession = nil
		self.videoDevice = nil
	}
	
	func startWriting() {
		
		self.recordStopButton.title = "Stop"
		self.fpsLabel.title = "00:00"
		
		self.captureSessionQueue.async {
			
			// remove the temp file, if any
			let outputFileURL: URL = FileManager.default.temporaryDirectory.appendingPathComponent(kTempVideoFilename)
			if FileManager.default.fileExists(atPath: outputFileURL.path) {
				try! FileManager.default.removeItem(at: outputFileURL)
			}
			var newAssetWriter: AVAssetWriter!
			do {
				newAssetWriter = try AVAssetWriter(outputURL: outputFileURL, fileType: AVFileType.m4v)
			}
			catch {
				self.showAlertWith(message: "Cannot create asset writer, error: \(error)")
			}
			
			let videoCompressionSettings: [String: Any] = [AVVideoCodecKey: AVVideoCodecType.h264, AVVideoWidthKey: self.currentVideoDimensions.width, AVVideoHeightKey: self.currentVideoDimensions.height]
			
			self.assetWriterVideoInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoCompressionSettings)
			self.assetWriterVideoInput.expectsMediaDataInRealTime = true
			
			// create a pixel buffer adaptor for the asset writer; we need to obtain pixel buffers for rendering later from its pixel buffer pool
			let sourcePixelBufferAttributes: [String: Any] = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA, kCVPixelBufferWidthKey as String: self.currentVideoDimensions.width, kCVPixelBufferHeightKey as String: self.currentVideoDimensions.height, kCVPixelFormatOpenGLESCompatibility as String: true]
			self.assetWriterInputPixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: self.assetWriterVideoInput, sourcePixelBufferAttributes: sourcePixelBufferAttributes)
			
			let orientation = (UIApplication.shared.delegate as! AppDelegate).realDeviceOrientation
			
			// give correct orientation information to the video
			if self.videoDevice.position == .front {
				self.assetWriterVideoInput.transform = FCGetTransformForDeviceOrientation(orientation, mirrored: true)
			}
			else {
				self.assetWriterVideoInput.transform = FCGetTransformForDeviceOrientation(orientation, mirrored: false)
			}
			
			let canAddInput: Bool = newAssetWriter.canAdd(self.assetWriterVideoInput)
			if !canAddInput {
				self.showAlertWith(message: "Cannot add asset writer video input")
				self.assetWriterAudioInput = nil
				self.assetWriterVideoInput = nil
				return
			}
			newAssetWriter.add(self.assetWriterVideoInput)
			
			if self.audioDevice != nil {
				var layoutSize: size_t = 0
				let channelLayout: UnsafePointer<AudioChannelLayout> = CMAudioFormatDescriptionGetChannelLayout(self.currentAudioSampleBufferFormatDescription, &layoutSize)!
				let basicDescription: UnsafePointer<AudioStreamBasicDescription> = CMAudioFormatDescriptionGetStreamBasicDescription(self.currentAudioSampleBufferFormatDescription)!
				
				let channelLayoutData: Data = Data(bytes: channelLayout, count: layoutSize)
				
				// record the audio at AAC format, bitrate 64000, sample rate and channel number using the basic description from the audio samples
				let audioCompressionSettings: [String: Any] = [AVFormatIDKey: kAudioFormatMPEG4AAC, AVNumberOfChannelsKey: basicDescription.pointee.mChannelsPerFrame, AVSampleRateKey: basicDescription.pointee.mSampleRate, AVEncoderBitRateKey: 64000, AVChannelLayoutKey: channelLayoutData]
				
				if newAssetWriter.canApply(outputSettings: audioCompressionSettings, forMediaType: .audio) {
					self.assetWriterAudioInput = AVAssetWriterInput(mediaType: .audio, outputSettings: audioCompressionSettings)
					self.assetWriterAudioInput.expectsMediaDataInRealTime = true
					
					if newAssetWriter.canAdd(self.assetWriterAudioInput) {
						newAssetWriter.add(self.assetWriterAudioInput)
					}
					else {
						self.showAlertWith(title: "Warning", message: "Couldn't add asset writer audio input")
					}
				}
				else {
					self.showAlertWith(title: "Warning", message: "Couldn't apply audio output settings.")
				}
			}
			
			// Make sure we have time to finish saving the movie if the app is backgrounded during recording
			// cf. the RosyWriter sample app from WWDC 2011
			if UIDevice.current.isMultitaskingSupported {
				self.backgroundRecordingID = UIApplication.shared.beginBackgroundTask(expirationHandler: { })
			}
			
			self.videoWritingStarted = false
			self.assetWriter = newAssetWriter

			
		}
	}
	
	func abortWriting() {
		guard self.assetWriter != nil else {return}
		
		self.assetWriter.cancelWriting()
		
		self.assetWriterAudioInput = nil
		self.assetWriterVideoInput = nil
		self.assetWriter = nil
		
		// remove the temp file
		let fileURL = self.assetWriter.outputURL
		try! FileManager.default.removeItem(at: fileURL)
		
		let resetUI = DispatchWorkItem {
			self.recordStopButton.title = "Record"
			self.recordStopButton.isEnabled = true
			
			// end the background task if it's done there
			// cf. The RosyWriter sample app from WWDC 2011
			if UIDevice.current.isMultitaskingSupported {
				UIApplication.shared.endBackgroundTask(self.backgroundRecordingID)
			}
		}
		
		DispatchQueue.main.async(execute: resetUI)
		
	}
	
	func stopWriting() {
		guard self.assetWriter != nil else {return}
		
		let writer: AVAssetWriter = self.assetWriter
		
		self.assetWriterAudioInput = nil
		self.assetWriterVideoInput = nil
		self.assetWriterInputPixelBufferAdaptor = nil
		self.assetWriter = nil

		self.stopLabelUpdateTimer()
		self.fpsLabel.title = "Saving..."
		self.recordStopButton.isEnabled = false
		
		let resetUI = DispatchWorkItem {
			self.recordStopButton.title = "Record"
			self.recordStopButton.isEnabled = true
			
			// end the background task if it's done there
			// cf. The RosyWriter sample app from WWDC 2011
			if UIDevice.current.isMultitaskingSupported {
				UIApplication.shared.endBackgroundTask(self.backgroundRecordingID)
			}
		}
		
		self.captureSessionQueue.async {
			let fileURL = writer.outputURL
			
			writer.finishWriting {
				if writer.status == .failed {
					DispatchQueue.main.async(execute: resetUI)
					
					self.showAlertWith(message: "Cannot complete writing the video, the output could be corrupt.")
				}
				else if writer.status == .completed {
					//Warning: Save video in photoLibrary
					
				}
				DispatchQueue.main.async(execute: resetUI)
			}
		}
	}
	
	func startLabelUpdateTimer() {
		self.labelUpdateTimer = Timer.scheduledTimer(timeInterval: kFPSLabelUpdateInterval, target: self, selector: #selector(updateLabel(timer:)), userInfo: nil, repeats: true)
	}
	
	func stopLabelUpdateTimer() {
		self.labelUpdateTimer?.invalidate()
		self.labelUpdateTimer = nil
	}
	
	@objc func updateLabel(timer: Timer) {
		let frameRate = String(format: "%.1f fps", arguments: [self.frameRateCalculator.frameRate])
		self.fpsLabel.title = frameRate
		
		if self.assetWriter != nil {
			let diff = CMTimeSubtract(self.currentVideoTime, self.videoWrtingStartTime)
			let seconds = CMTimeGetSeconds(diff)
			
			self.fpsLabel.title = "\(seconds/60):\(seconds.truncatingRemainder(dividingBy: 60))"
		}
	}
	
	//MARK: - NotificationCenter handlers
	
	@objc func handleAttributeValueUpdate(_ notification: Notification) {
		let info = notification.userInfo!
		let filter: CIFilter? = info[kFilterObject] as? CIFilter
		let key: String? = info[kFilterInputKey] as? String
		let value = info[kFilterInputValue]
		
		if filter != nil && key != nil && value != nil {
			self.captureSessionQueue.async {
				filter!.setValue(value, forKey: key!)
			}
		}
	}
	
	@objc func handleFHFilterImageAttributeSourceChange(_ notification: Notification) {
		self.handleFilterStackActiveFilterListDidChangeNotification(notification)
	}
	
	@objc func handleSettingUpdate(_ notification: Notification) {
		let userInfo = notification.userInfo
		let updatedKey: String = userInfo![kFHSettingUpdatedKeyNameKey] as! String
		
		if updatedKey == kFHSettingColorMatchKey {
			let colormatch = UserDefaults.standard.bool(forKey: updatedKey)
			let options: [String: Any]? = colormatch ? [kCIContextWorkingColorSpace: NSNull()] : nil
			
			self.captureSessionQueue.async {
				self.ciContext = CIContext(eaglContext: self.eagleContext, options: options)
			}
		}
		
		self.stop()
		self.start()
	}

	@objc func handleFilterStackActiveFilterListDidChangeNotification(_ notification: Notification) {

		// the active filter list gets updated, and we use this to ensure that the our _activeFilters array gets changed in the designated queue (to avoid the race condition where _activeFilters is being used by RunFilter()
		let newActiveFilters = self.filterStack.activeFilters
		self.captureSessionQueue.async {
			self.activeFilters = newActiveFilters
		}
		
		self.fpsLabel.isEnabled = self.filterStack.containsVideoSource
		self.recordStopButton.isEnabled = self.filterStack.containsVideoSource
	}
	
	@objc func handleAVCaptureSessionWasInterruptedNotification(_ notification: Notification) {
		self.stopWriting()
	}
	
	@objc func handleUIApplicationDidEnterBackgroundNotification(_ notification: Notification) {
		self.stopWriting()
	}
	
	@objc func handleRotation() {
//		self.layout(videoPreviewView!, to: window)
		
		videoPreviewView?.frame = window.bounds

	}
	
	func showAlertWith(title: String = "Error", message: String) {
		let alertView = UIAlertController(title: title, message: message, preferredStyle: .alert)
		let action = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
		alertView.addAction(action)
		self.present(alertView, animated: true, completion: nil)
	}
	
	//MARK: - Delegate methods
	
	func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
		
		let formatDesc: CMFormatDescription = CMSampleBufferGetFormatDescription(sampleBuffer)!
		let mediaType: CMMediaType = CMFormatDescriptionGetMediaType(formatDesc)

		// write the audio data if it's from the audio connection
		if mediaType == kCMMediaType_Audio {

			self.currentAudioSampleBufferFormatDescription = formatDesc
			
			// we need to retain the sample buffer to keep it alive across the different queues (threads)
			if assetWriter != nil && self.assetWriterAudioInput.isReadyForMoreMediaData && !self.assetWriterAudioInput.append(sampleBuffer) {
				self.showAlertWith(message: "Cannot write audio data, recording aborted")
				self.abortWriting()
			}
			return
		}
		
		// if not from the audio capture connection, handle video writing
		let timestamp: CMTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
		
		self.frameRateCalculator.calculateFrameRate(at: timestamp)
		
		// update the video dimensions information
		self.currentVideoDimensions = CMVideoFormatDescriptionGetDimensions(formatDesc)
		
		let imageBuffer: CVImageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!
		
		let sourceImage: CIImage = CIImage(cvPixelBuffer: imageBuffer)
		
		// run the filter through the filter chain
		let filteredImage: CIImage? = runFilter(cameraImage: sourceImage, filters: self.activeFilters)
		
		let sourceExtent = sourceImage.extent
		
		let sourceAspect: CGFloat = sourceExtent.size.width / sourceExtent.size.height
		let previewAspect: CGFloat = self.videoPreviewViewBounds.size.width  / self.videoPreviewViewBounds.size.height
		
		// we want to maintain the aspect radio of the screen size, so we clip the video image
		var drawRect: CGRect = sourceExtent
		
		if sourceAspect > previewAspect {
			
			// use full height of the video image, and center crop the width
			drawRect.origin.x += (drawRect.size.width - drawRect.size.height * previewAspect) / 2.0
			drawRect.size.width = drawRect.size.height * previewAspect
		}
		else {
			
			// use full width of the video image, and center crop the height
			drawRect.origin.y += (drawRect.size.height - drawRect.size.width / previewAspect) / 2.0
			drawRect.size.height = drawRect.size.width / previewAspect
		}
		
		if assetWriter == nil {
			self.videoPreviewView?.bindDrawable()
			
			if self.eagleContext != EAGLContext.current() {
				EAGLContext.setCurrent(self.eagleContext)
			}
			
			// clear eagl view to grey
			glClearColor(0.5, 0.5, 0.5, 1.0)
			glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
			
			// set the blend mode to "source over" so that CI will use that
			glEnable(GLenum(GL_BLEND))
			glBlendFunc(GLenum(GL_ONE), GLenum(GL_ONE_MINUS_SRC_ALPHA))
			
			if filteredImage != nil {
				ciContext.draw(filteredImage!, in: self.videoPreviewViewBounds, from: drawRect)
			}
			
			self.videoPreviewView?.display()
		}
		else {
			
			// if we need to write video and haven't started yet, start writing
			if !self.videoWritingStarted {
				self.videoWritingStarted = true
				
				let success = self.assetWriter.startWriting()
				
				if !success {
					self.showAlertWith(message: "Cannot write video data, recording aborted")
					self.abortWriting()
					return
				}
				
				self.assetWriter.startSession(atSourceTime: timestamp)
				self.videoWrtingStartTime = timestamp
				self.currentVideoTime = self.videoWrtingStartTime
			}
			
			var renderedOutputPixelBuffer: CVPixelBuffer? = nil
			
			let err: OSStatus = CVPixelBufferPoolCreatePixelBuffer(nil, self.assetWriterInputPixelBufferAdaptor.pixelBufferPool!, &renderedOutputPixelBuffer)
			
			if err == 0 {
				print("Cannot obtain a pixel buffer from the buffer pool")
				return
			}
			
			
			// render the filtered image back to the pixel buffer (no locking needed as CIContext's render method will do that
			if filteredImage != nil {
				self.ciContext.render(filteredImage!, to: renderedOutputPixelBuffer!, bounds: filteredImage!.extent, colorSpace: nil)
			}
			
			
			// pass option nil to enable color matching at the output, otherwise the color will be off
			let drawImage = CIImage(cvImageBuffer: renderedOutputPixelBuffer!)
			
			self.videoPreviewView?.bindDrawable()
			self.ciContext.draw(drawImage, in: self.videoPreviewViewBounds, from: drawRect)
			self.videoPreviewView?.display()
			
			self.currentVideoTime = timestamp
			
			// write the video data
			if assetWriterVideoInput.isReadyForMoreMediaData {
				self.assetWriterInputPixelBufferAdaptor.append(renderedOutputPixelBuffer!, withPresentationTime: timestamp)
			}
			
		}
	}
	
	func filterListEditorDidDismiss() {
		UIApplication.shared.isStatusBarHidden = true
		self.dismiss(animated: true) {
			self.recordStopButton.isEnabled = self.filterStack.containsVideoSource
		}
	}
	
	func settingsDidDismiss() {
		UIApplication.shared.isStatusBarHidden = true
		self.dismiss(animated: true) {
			self.recordStopButton.isEnabled = self.filterStack.containsVideoSource
		}
	}
	
	func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
		if popoverPresentationController == self.settingsPopoverController {
			self.settingsDidDismiss()
		}
		
		if popoverPresentationController == self.filterListPopoverController {
			self.filterListEditorDidDismiss()
		}
	}
	
}

