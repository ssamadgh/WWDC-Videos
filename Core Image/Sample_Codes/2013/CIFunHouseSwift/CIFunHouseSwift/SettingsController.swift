//
//  SettingsController.swift
//  CIFunHouseSwift
//
//  Created by Seyed Samad Gholamzadeh on 8/9/1396 AP.
//  Copyright © 1396 AP Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit
import AVFoundation

protocol SettingsControllerDelegate: AnyObject {
	func settingsDidDismiss()
}

let kFHSettingCameraPositionKey = "CameraPosition"
let kFHSettingCaptureSessionPresetKey = "CaptureSessionPreset"
let kFHSettingColorMatchKey = "ColorMatch"
let kFHSettingDidUpdateNotification = "kFHSettingDidUpdateNotification"
let kFHSettingUpdatedKeyNameKey = "Key"
let kFHFilterImageAttributeSourceDidChangeNotification = "FHFilterImageAttributeSourceDidChangeNotification"

func FCApplyDefaultSettings(reset: Bool) {
	
	let defaults = UserDefaults.standard
	
	if reset || (defaults.integer(forKey: kFHSettingCameraPositionKey) == 0) {
		defaults.set(AVCaptureDevice.Position.back.rawValue, forKey: kFHSettingCameraPositionKey)
	}
	
	if reset || (defaults.object(forKey: kFHSettingCaptureSessionPresetKey) == nil) {
		if UIDevice.current.userInterfaceIdiom == .pad {
			defaults.set(AVCaptureSession.Preset.high.rawValue, forKey: kFHSettingCaptureSessionPresetKey)
		}
		else {
			defaults.set(AVCaptureSession.Preset.vga640x480.rawValue, forKey: kFHSettingCaptureSessionPresetKey)
		}
	}
}

func FCPopulateDefaultSettings() {
	FCApplyDefaultSettings(reset: false)
}

enum Settings: Int {
	case cameraPositionGroup
	case capturePresetGroup
	case colorMatchGroup
	case groupCount
}

enum ColorMatch: Int {
	case enabled, disabled
}

let kTitleKey = "Title"
let kEnabledKey = "Enabled"


class SettingsController: UITableViewController {
	
	var cameraPositions: Array<Int>
	var cameraPositionData: [Int: [String: Any]]
	var presets: [String]
	var presetsData: [String: [String: Any]]
	var colorMatchModes: [Int]
	var colorMatchData: [Int: [String: Any]]
	
	var delegate: SettingsControllerDelegate!
	
	override init(style: UITableViewStyle) {
		
		// populate default settings
		FCPopulateDefaultSettings()
		
		cameraPositions = [AVCaptureDevice.Position.back.rawValue, AVCaptureDevice.Position.front.rawValue]
		
		cameraPositionData = [:]
		cameraPositionData[AVCaptureDevice.Position.back.rawValue] = [kTitleKey: "Back"]
		cameraPositionData[AVCaptureDevice.Position.front.rawValue] = [kTitleKey: "Front"]

		presets = [AVCaptureSession.Preset.medium.rawValue, AVCaptureSession.Preset.high.rawValue]
		
		presetsData = [:]
		presetsData[AVCaptureSession.Preset.medium.rawValue] = [kTitleKey: "Medium"]
		presetsData[AVCaptureSession.Preset.high.rawValue] = [kTitleKey: "High"]

		colorMatchModes = [ColorMatch.disabled.rawValue, ColorMatch.enabled.rawValue]
		
		colorMatchData = [:]
		colorMatchData[ColorMatch.disabled.rawValue] = [kTitleKey: "Disabled"]
		colorMatchData[ColorMatch.enabled.rawValue] = [kTitleKey: "Enabled"]
		
		super.init(style: style)
		self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
		
		// Disable by default
		UserDefaults.standard.set(ColorMatch.disabled.rawValue, forKey: kFHSettingColorMatchKey)
		
		NotificationCenter.default.addObserver(self, selector: #selector(handleCaptureSessionDidStart(_:)), name: NSNotification.Name(FHViewControllerDidStartCaptureSessionNotification), object: nil)
		
		self.validateSettings()
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
	
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	//MARK: - View lifecycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		if UIDevice.current.userInterfaceIdiom == .phone {
			self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissAction))
		}
		
		self.title = "Settings"
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	// MARK: - Table view data source
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		// #warning Incomplete implementation, return the number of sections
		return Settings.groupCount.rawValue
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		// #warning Incomplete implementation, return the number of rows
		switch (section) {
		case Settings.cameraPositionGroup.rawValue: return cameraPositions.count
		case Settings.capturePresetGroup.rawValue: return presets.count
		case Settings.colorMatchGroup.rawValue: return colorMatchModes.count
		default: return 0;
		}
	}
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		switch (section) {
		case Settings.cameraPositionGroup.rawValue: return "Camera Position"
		case Settings.capturePresetGroup.rawValue: return "Preset"
		case Settings.colorMatchGroup.rawValue: return "Color Management"
		default: return "(Invalid)"
		}

	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cellIdentifier = "cell"
		let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
		
		// Configure the cell...

		var item: AnyHashable!
		var modes: [AnyHashable]!
		var data: [AnyHashable: [String: Any]]!
		var key: String!
		
		switch (indexPath.section) {
		case Settings.cameraPositionGroup.rawValue:
			modes = cameraPositions
			data = cameraPositionData
			key = kFHSettingCameraPositionKey
			
		case Settings.capturePresetGroup.rawValue:
			modes = presets
			data = presetsData
			key = kFHSettingCaptureSessionPresetKey

		case Settings.colorMatchGroup.rawValue:
			modes = colorMatchModes
			data = colorMatchData
			key = kFHSettingColorMatchKey;
		default: break
		}
		
		cell.accessoryType = .none
		
		if modes != nil {
			
			item = modes[indexPath.row]
			cell.textLabel?.text = data[item]![kTitleKey] as? String
			let enabled = data![item!]![kEnabledKey] as? Bool ?? false
			
			if enabled {
				
				if (UserDefaults.standard.object(forKey: key) as! AnyHashable) == item {
					cell.accessoryType = .checkmark
				}
					cell.textLabel?.textColor = .black
					cell.selectionStyle = .blue
			}
			else {
				cell.textLabel?.textColor = .gray
				cell.selectionStyle = .none
			}
		}
		
	return cell
	}
	
	override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
		var modes: [AnyHashable]?
		var data: [AnyHashable: [String: Any]]?
		
		switch (indexPath.section) {
		case Settings.cameraPositionGroup.rawValue:
			modes = cameraPositions
			data = cameraPositionData
			
		case Settings.capturePresetGroup.rawValue:
			modes = presets
			data = presetsData
			
		case Settings.colorMatchGroup.rawValue:
			modes = colorMatchModes;
			data = colorMatchData;

		default: break
		}
		
		let enabled = data![modes![indexPath.row]]![kEnabledKey] as! Bool
		
		return enabled ? indexPath : nil
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let userDefaults = UserDefaults.standard
		
		var item: AnyHashable?
		
		var oldRow: Int?
		var newRow: Int
		
		var array: [AnyHashable]?
//		var data: [AnyHashable: [String: Any]]?
		var key: String?
		
		switch (indexPath.section) {
		case Settings.cameraPositionGroup.rawValue:
			array = cameraPositions
			key = kFHSettingCameraPositionKey
			
		case Settings.capturePresetGroup.rawValue:
			array = presets
			key = kFHSettingCaptureSessionPresetKey
			
		case Settings.colorMatchGroup.rawValue:
			array = colorMatchModes;
			key = kFHSettingColorMatchKey;
		default: break
		}
		
		item = array?[indexPath.row]
		oldRow = array?.index(of: userDefaults.object(forKey: key!) as! AnyHashable)
		newRow = indexPath.row
		if oldRow != nil {
			self.tableView.cellForRow(at: IndexPath(row: oldRow!, section: indexPath.section))?.accessoryType = .none
		}
		
		self.tableView.cellForRow(at: IndexPath(row: newRow, section: indexPath.section))?.accessoryType = .checkmark
		self.tableView.deselectRow(at: indexPath, animated: true)
		
		if (userDefaults.object(forKey: key!) as! AnyHashable) != item!.hashValue as AnyHashable {
			userDefaults.set(item, forKey: key!)
		}
		else {
			return
		}
		
		let userInfo = [kFHSettingUpdatedKeyNameKey: key!]
		
		NotificationCenter.default.post(name: NSNotification.Name(kFHSettingDidUpdateNotification), object: nil, userInfo: userInfo)
		
		self.title = "Applying..."
		self.tableView.isUserInteractionEnabled = false
		self.navigationItem.leftBarButtonItem?.isEnabled = false
	}
	
	//MARK: - Private methods
	
	@objc func dismissAction() {
		self.delegate.settingsDidDismiss()
	}
	
	@objc func handleCaptureSessionDidStart(_ notification: Notification) {
		self.tableView.reloadData()
		self.title = "Settings"
		self.tableView.isUserInteractionEnabled = true
		self.navigationItem.leftBarButtonItem?.isEnabled = true
	}
	
	func validateSettings() {
		let userDefaults = UserDefaults.standard
		let position = AVCaptureDevice.Position(rawValue: userDefaults.integer(forKey: kFHSettingCameraPositionKey))!
		var videoDevice: AVCaptureDevice? = nil

		let videoDevices = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInTelephotoCamera, .builtInDualCamera, .builtInWideAngleCamera, .builtInMicrophone], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.unspecified)

		for device in videoDevices.devices {

			cameraPositionData[device.position.rawValue]![kEnabledKey] = true
			if device.position == position {
				videoDevice = device
			}
		}
		
		if videoDevice == nil { return }
		
		for preset in self.presets {
			self.presetsData[preset]![kEnabledKey]  = videoDevice?.supportsSessionPreset(AVCaptureSession.Preset(rawValue: preset))
		}
		
		for key in self.colorMatchModes {
			colorMatchData[key]![kEnabledKey] = true
		}
	}
	
}
