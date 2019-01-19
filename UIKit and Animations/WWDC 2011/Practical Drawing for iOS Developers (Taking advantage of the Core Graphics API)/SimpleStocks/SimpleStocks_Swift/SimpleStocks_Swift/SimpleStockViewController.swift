//
//  ViewController.swift
//  SimpleStocks_Swift
//
//  Created by Seyed Samad Gholamzadeh on 4/17/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//
// Abstract: This view controller handles orientation changes and acts as the data source for SimpleStockView.


import UIKit

class SimpleStockViewController: UIViewController, SimpleStockViewDataSource {

	//MARK: - View lifecycle
	
	override func viewDidLoad() {
		super.viewDidLoad()

		let view = SimpleStockView()
		view.dataSource = self
		self.view = view
	}

	//MARK: - GraphViewDataSource methods
	
	// these methods should be using Core Data rather than a simple in memory
	// array, but this sample is focused on drawing rather than interaction with a
	// data service.
	
	/*
	* return the number of model objects that will contribute to the graph
	*/
	func graphViewDailyTradeInfoCount(_ graphView: SimpleStockView) -> Int {
		return DailyTradeInfoSource.dailyTradeInfos.count
	}
	
	/*
	* return the month names to be drawn
	*/
	func graphViewSortedMonths(_ graphView: SimpleStockView) -> [DateComponents] {
		let calendar = Calendar.current
		let closingDates = DailyTradeInfoSource.dailyTradeInfos.compactMap { $0.tradingDate }
		var months: Set<DateComponents> = []
		for closingDate in closingDates {
			months.insert(calendar.dateComponents([.month], from: closingDate))
		}

		return months.sorted { $0.month! < $1.month! }
	}
	
	
	/*
	* For the given month (in components) return the number of trades
	* some months have 20 trading days, some have 23
	* this method makes it possible for us to layout the months names accordingly
	*/
	func graphView(_ graphView: SimpleStockView, tradeCountForMonth components: DateComponents) -> Int {
		let calendar = Calendar.current
		let closingDates = DailyTradeInfoSource.dailyTradeInfos.compactMap { $0.tradingDate }
		
		var months: Array<DateComponents> = []
		for closingDate in closingDates {
			months.append(calendar.dateComponents([.month], from: closingDate))
		}
		let filteredMonth = months.filter { $0 == components }
		return filteredMonth.count
	}
	
	/*
	* Return the model objects
	*/
	func graphViewDailyTradeInfos(_ graphView: SimpleStockView) -> [DailyTradeInfo] {
		return DailyTradeInfoSource.dailyTradeInfos
	}
	
	/*
	* Return the max closing price
	*/
	func graphViewMaxClosingPrice(_ graphView: SimpleStockView) -> CGFloat {
		return CGFloat(DailyTradeInfoSource.dailyTradeInfos.compactMap { $0.closingPrice.floatValue}.max()!)
	}
	
	
	/*
	* Return the min closing price
	*/
	func graphViewMinClosingPrice(_ graphView: SimpleStockView) -> CGFloat {
		return CGFloat(DailyTradeInfoSource.dailyTradeInfos.compactMap { $0.closingPrice.floatValue}.min()!)
	}
	
	
	/*
	* Return the max trading volume
	*/
	func graphViewMaxTradingVolume(_ graphView: SimpleStockView) -> CGFloat {
		return CGFloat(DailyTradeInfoSource.dailyTradeInfos.compactMap { $0.tradingVolume.floatValue}.max()!)
	}
	
	
	/*
	* Return the min trading volume
	*/
	func graphViewMinTradingVolume(_ graphView: SimpleStockView) -> CGFloat {
		return CGFloat(DailyTradeInfoSource.dailyTradeInfos.compactMap { $0.tradingVolume.floatValue}.min()!)
	}

}

