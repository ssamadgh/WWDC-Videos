//
//  CameraCaptureViewController.swift
//  Running with a Snap - Swift
//
//  Created by Seyed Samad Gholamzadeh on 7/13/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

class CameraCaptureViewController: UIViewController, AVCapturePhotoCaptureDelegate {

	@IBOutlet weak var  videoHostView: UIView!
	@IBOutlet weak var  controlsView: UIView!

	var run: Run!
	var previewLayer: AVCaptureVideoPreviewLayer!
	var session: AVCaptureSession!
	var stillOutput: AVCapturePhotoOutput!
	var captureTimer: Timer!
	var lowPowerAlertID: SystemSoundID = SystemSoundID(bitPattern: 0)
	
    override func viewDidLoad() {
        super.viewDidLoad()

		
		do {
			try self.setupCameraStream()
		}
		catch {
			let alert = UIAlertController(title: "Stream setup error", message: error.localizedDescription, preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "Close", style: .cancel, handler: { (action) in
				//...
				self.finishCapture(nil)
			}))
			self.present(alert, animated: true, completion: nil)
			return
		}
		
		let tap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped(_:)))
		tap.numberOfTapsRequired = 2
		self.view.addGestureRecognizer(tap)
		
		self.previewLayer = AVCaptureVideoPreviewLayer(session: self.session)
		self.previewLayer.bounds = self.view.bounds
		self.previewLayer.position = self.view.center
		self.videoHostView.layer.addSublayer(self.previewLayer)
				
		let deviceOrientation = UIDevice.current.orientation
		guard let newVideoOrientation = AVCaptureVideoOrientation(rawValue: deviceOrientation.rawValue),
			deviceOrientation.isPortrait || deviceOrientation.isLandscape else {
				return
		}
		let previewConnection = self.previewLayer.connection
		previewConnection?.videoOrientation = newVideoOrientation

		
		self.session.startRunning()
    }

	func playAlertSound() {
		if self.lowPowerAlertID == nil {
			var fileURL: URL? = nil
			fileURL = Bundle.main.url(forResource: "<YOUR_ALERT_SOUND>", withExtension: "wav")
			if fileURL == nil {
				print("Look at -[CameraCaptureViewController _playAlertSound] and provide your own audio file to play when power gets low.")
			}
			
			AudioServicesCreateSystemSoundID(fileURL! as CFURL, &self.lowPowerAlertID)
		}
		
		if self.lowPowerAlertID != nil {
			AudioServicesPlayAlertSound(self.lowPowerAlertID)
		}
	}
	
	func checkBatteryLevel() {
		if UIDevice.current.isBatteryMonitoringEnabled {
			let batteryLevel = UIDevice.current.batteryLevel
			if batteryLevel < 0.05 {
				self.playAlertSound()
			}
		}
	}
	
	func setupCameraStream() throws {
		let backCamera = AVCaptureDevice.default(AVCaptureDevice.DeviceType.builtInWideAngleCamera, for: AVMediaType.video, position: AVCaptureDevice.Position.back)
		if backCamera == nil {
			let error = NSError(domain: "RunningWithASnap", code: 1, userInfo: [NSLocalizedDescriptionKey: "Could not find a back camera and one is required."])
			throw(error)
		}
		do {
			try backCamera?.lockForConfiguration()
			backCamera?.focusMode = .autoFocus
			// This appears to be bad... pictures are always blurry.
			//        backCamera.focusMode = AVCaptureFocusModeContinuousAutoFocus;
			backCamera?.exposureMode = .autoExpose
//			backCamera?.flashMode = .off
			backCamera?.torchMode = .off
			backCamera?.whiteBalanceMode = .continuousAutoWhiteBalance
			backCamera?.unlockForConfiguration()
		}
		catch {
			let error = NSError(domain: "RunningWithASnap", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to lock camera for configuration."])
			throw(error)

		}
		
		let inputCapture = try AVCaptureDeviceInput(device: backCamera!)
		self.session = AVCaptureSession()
		self.session.sessionPreset = .high
		
//		self.session.sessionPreset = .photo

		if !self.session.canAddInput(inputCapture) {
			let error = NSError(domain: "RunningWithASnap", code: 3, userInfo: [NSLocalizedDescriptionKey: "Unable to add back camera as input to capture session."])
			throw(error)
		}
		self.session.addInput(inputCapture)
		self.stillOutput = AVCapturePhotoOutput()
		
		if !self.session.canAddOutput(self.stillOutput) {
			let error = NSError(domain: "RunningWithASnap", code: 4, userInfo: [NSLocalizedDescriptionKey: "Unable to add still image output to capture session."])
			throw(error)
		}
		self.session.addOutput(self.stillOutput)
		
		let conn = self.stillOutput.connection(with: .video)
		conn?.videoOrientation = .portrait
	}
	
	@IBAction func toggleCapture(_ sender: Any) {
		if self.captureTimer != nil {
			UIDevice.current.isBatteryMonitoringEnabled = false
			self.captureTimer.invalidate()
			self.captureTimer = nil
			(sender as! UIButton).setTitle("Start Capture", for: .normal)
		}
		else {
			// Start battery monitoring
			UIDevice.current.isBatteryMonitoringEnabled = true
			self.captureTimer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(attemptStillCapture(timer:)), userInfo: nil, repeats: true)
			(sender as! UIButton).setTitle("Start Capture", for: .normal)
		}
	}
	
	@IBAction func togglePreview(_ sender: Any) {
		let previewConnection = self.previewLayer.connection!
		previewConnection.isEnabled = !previewConnection.isEnabled
		if previewConnection.isEnabled {
			(sender as! UIButton).setTitle("Hide Preview", for: .normal)
		}
		else {
			(sender as! UIButton).setTitle("Show Preview", for: .normal)
		}
	}
	
	@objc func attemptStillCapture(timer: Timer) {
		self.checkBatteryLevel()
		
		let deviceOrientation = UIDevice.current.orientation
		guard let newVideoOrientation = AVCaptureVideoOrientation(rawValue: deviceOrientation.rawValue),
			deviceOrientation.isPortrait || deviceOrientation.isLandscape else {
				return
		}
		let connection = self.stillOutput.connection(with: .video)
		connection?.videoOrientation = newVideoOrientation

		if connection == nil {
			print("failed to get connection from stillOutput")
			self.playAlertSound()
			return
		}
		
		let setting = AVCapturePhotoSettings()
		setting.flashMode = .off
		self.stillOutput.capturePhoto(with: setting, delegate: self)
	}
	
	func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
		if error != nil {
			print("captureStillImageAsynchronouslyFromConnection error: \(error!)")
			self.playAlertSound()
		}
		else {
			if let cgImage = photo.cgImageRepresentation()?.takeUnretainedValue() {
				if self.run != nil {
					do {
						let image = UIImage(cgImage: cgImage)
						try self.run.save(UIImageJPEGRepresentation(image, 1)!)
					}
					catch {
						fatalError(error.localizedDescription)
					}
				}
			}
		}
	}
	
	@IBAction func finishCapture(_ sender: Any?) {
		if self.captureTimer != nil {
			self.session.stopRunning()
			self.captureTimer.invalidate()
			self.captureTimer = nil
			let newViewControllers: [UIViewController] = [self.navigationController!.viewControllers.first!, PreviousRunPickerViewController(nibName: nil, bundle: nil)]
			self.navigationController?.setNavigationBarHidden(false, animated: false)
			self.navigationController?.setViewControllers(newViewControllers, animated: true)
			
		}
		else {
			self.navigationController?.popViewController(animated: true)
		}
	}
	
	@objc func doubleTapped(_ tapGesture: UITapGestureRecognizer) {
		self.finishCapture(nil)
	}
}
