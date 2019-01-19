//
//  DailyTradeInfo.swift
//  SimpleStocks_Swift
//
//  Created by Seyed Samad Gholamzadeh on 4/17/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

// a simple model object to keep track of the daily trade data
class DailyTradeInfo: NSObject {

	var tradingDate: Date!
	var openingPrice: NSNumber!
	var highPrice: NSNumber!
	var lowPrice: NSNumber!
	var closingPrice: NSNumber!
	var tradingVolume: NSNumber!

	/*
	* simple debugging info
	*/
	override var description: String {
		return "\(self.tradingDate), \(self.closingPrice)"
	}
	
	/*
	* compare trading info's based on their trade date so they sort acording to their date
	*/
	func compare(_ other: DailyTradeInfo) -> ComparisonResult {
		return self.tradingDate.compare(other.tradingDate)
	}
	
}
