//
//  AAPLLayoutMetrics.swift
//  AdvancedCollectionView_Swift
//
//  Created by Seyed Samad Gholamzadeh on 10/14/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

/*
Abstract:
Classes used to define the layout metrics.
*/

import UIKit

/// The element kind for placeholders. In general, it's unlikely this will be needed.
let AAPLCollectionElementKindPlaceholder: String = "AAPLCollectionElementKindPlaceholder"

/// A marker value for elements that should be sized automatically based on their constraints.
let AAPLCollectionViewAutomaticHeight: CGFloat  = -1000

/// The index of the global header & footer section
let AAPLGlobalSectionIndex: Int = Int.max


class AAPLSupplementaryItem: NSObject, AAPLSupplementaryItemProtocol {
	
	var isVisibleWhileShowingPlaceholder: Bool = true
	
	var shouldPin: Bool = true
	
	var height: CGFloat
	
	var estimatedHeight: CGFloat
	
	var hasEstimatedHeight: Bool {
		return self.height == AAPLCollectionViewAutomaticHeight
	}
	
	var fixedHeight: CGFloat {
		if self.height == AAPLCollectionViewAutomaticHeight {
			return self.estimatedHeight
		}
		return self.height
	}
	
	required init(kind: String) {
		self.elementKind = kind
		self.height = AAPLCollectionViewAutomaticHeight;
		self.estimatedHeight = 44
		super.init()

	}
	
	var isHidden: Bool = false
	
	var layoutMargins: UIEdgeInsets = .zero
	
	var supplementaryViewClass: AnyClass?
	
	var backgroundColor: UIColor = .white
	
	var selectedBackgroundColor: UIColor = .gray
	
	var pinnedBackgroundColor: UIColor = .blue
	
	var separatorColor: UIColor = .black
	
	var pinnedSeparatorColor: UIColor = .red
	
	var showsSeparator: Bool = true
	
	var simulatesSelection: Bool = true
	
	var elementKind: String
	
	var _reuseIdentifier: String?

	var reuseIdentifier: String {
		get {
			guard let reuseId = self._reuseIdentifier else {
				return "\(type(of: self.supplementaryViewClass))"
			}
			return reuseId
		}
		
		set {
			self._reuseIdentifier = newValue
		}
	}
	
	var configureView: AAPLSupplementaryItemConfigurationBlock?
	
	func configure(with block: @escaping AAPLSupplementaryItemConfigurationBlock) {
		guard let oldConfigBlock = self.configureView else {
			self.configureView = block
			return
		}
		
		// chain the old with the new
		self.configureView = { ( view, dataSource, indexPath) in
			oldConfigBlock(view, dataSource, indexPath)
			block(view, dataSource, indexPath)
		}
	}
	
	func applyValues(from metrics: AAPLSupplementaryItemProtocol?) {
		
		guard let metrics = metrics else { return }
		
		self.layoutMargins = metrics.layoutMargins
		self.separatorColor = metrics.separatorColor
		self.pinnedSeparatorColor = metrics.pinnedSeparatorColor
		self.backgroundColor = metrics.backgroundColor
		self.pinnedBackgroundColor = metrics.pinnedBackgroundColor
		self.selectedBackgroundColor = metrics.selectedBackgroundColor
		self.height = metrics.height
		self.estimatedHeight = metrics.estimatedHeight
		self.isHidden = metrics.isHidden
		self.shouldPin = metrics.shouldPin
		self.isVisibleWhileShowingPlaceholder = metrics.isVisibleWhileShowingPlaceholder
		self.showsSeparator = metrics.showsSeparator

		self.supplementaryViewClass = metrics.supplementaryViewClass
		self.configureView = metrics.configureView
		self.reuseIdentifier = metrics.reuseIdentifier

	}
	
}
