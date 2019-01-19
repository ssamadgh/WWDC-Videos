//
//  APLSectionInfo.swift
//  TVAnimationsGestures_Swift
//
//  Created by Seyed Samad Gholamzadeh on 6/22/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit



class APLSectionInfo: NSObject {

	var isOpen: Bool!
	
	var play: APLPlay!
	
	var headerView: APLSectionHeaderView!
	
	var rowHeights: [CGFloat] = []
	
	var countOfRowHeights: Int {
		return rowHeights.count
	}
	
	override init() {
		super.init()
		
	}
	
	func objectInRowHeightsAtIndex(_ index: Int) -> CGFloat {
		return self.rowHeights[index]
	}
	
	func insert(_ object: CGFloat, inRowHeightsAt index: Int) {
		self.rowHeights.insert(object, at: index)
	}
	
	func insertRowHeights(_ rowHeightArray: [CGFloat], atIndexes indexes: IndexSet) {
		let indexesArray = Array(indexes)
		for (index, object) in rowHeightArray.enumerated() {
			self.rowHeights.insert(object, at: indexesArray[index])
		}
	}
	
	func removeObjectFromRowHeihtsAt(_ index: Int) {
		self.rowHeights.remove(at: index)
	}
	
	func removeRowHeightsAt(_ indexes: IndexSet) {
		let indexesArray = Array(indexes)
		
		for index in indexesArray {
			self.rowHeights.remove(at: index)
		}
	}
	
	func replaceObjectInRowHeightsAt(_ index: Int, with object: CGFloat) {
		self.rowHeights[index] = object
	}
	
	func replaceRowHeightsAt(_ indexes: IndexSet, withRowhHeights rowHeightArray: [CGFloat]) {
		let indexesArray = Array(indexes)
		for (index, object) in rowHeightArray.enumerated() {
			self.rowHeights[indexesArray[index]] = object
		}
	}

}
