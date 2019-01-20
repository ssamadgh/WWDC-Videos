//
//  Extension+NSLock.swift
//  AdvancedCollectionView_Swift
//
//  Created by Seyed Samad Gholamzadeh on 7/22/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import Foundation

extension NSLock {
	func withCriticalScope<T>(_ block: () -> T) -> T {
		lock()
		let value = block()
		unlock()
		return value
	}
}

