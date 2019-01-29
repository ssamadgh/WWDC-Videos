//
//  FrameRateCalculator.swift
//  CIFunHouseSwift
//
//  Created by Seyed Samad Gholamzadeh on 8/10/1396 AP.
//  Copyright © 1396 AP Seyed Samad Gholamzadeh. All rights reserved.
//

import Foundation
import AVFoundation

class FrameRateCalculator: NSObject {
	
	var previousSecondTimestamps: [NSValue]
	var frameRate: Float64 = 0.0
	
	override init() {
		previousSecondTimestamps = []
		
		super.init()
	}
	
	func reset() {
		previousSecondTimestamps.removeAll()
		frameRate = 0.0
	}
	
	func calculateFrameRate(at timestamp: CMTime) {
		previousSecondTimestamps.append(NSValue(time: timestamp))
		let oneSecond = CMTime(value: 1, timescale: 1)
		let oneSecondAgo = CMTimeSubtract(timestamp, oneSecond)
		
		
		CMTimeCompare(previousSecondTimestamps[0].timeValue, oneSecondAgo)
		
		while CMTimeCompare(previousSecondTimestamps[0].timeValue, oneSecondAgo) < 0 {
			previousSecondTimestamps.remove(at: 0)
		}
		
		let newRate = previousSecondTimestamps.count
		self.frameRate = (frameRate + Float64(newRate))/2
	}
}
