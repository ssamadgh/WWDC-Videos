//
//  SSTheme.swift
//  Spaceship_Swift
//
//  Created by Seyed Samad Gholamzadeh on 4/27/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

enum SSThemeTab: Int {
	case door, power, controls
}


protocol SSTheme {
	
	var mainColor: UIColor? { get }
	var highlightColor: UIColor? { get }
	var shadowColor: UIColor? { get }
	var backgroundColor: UIColor? { get }
	
	var baseTintColor: UIColor? { get }
	var accentTintColor: UIColor? { get }
	
	var switchThumbColor: UIColor? { get }
	var switchOnColor: UIColor? { get }
	var switchTintColor: UIColor? { get }

	var shadowOffset: CGSize { get }
	
	var topShadow: UIImage? { get }
	var bottomShadow: UIImage? { get }

	func navigationBackgroundForBarMetrics(_ metrics: UIBarMetrics) -> UIImage?
	func barButtonBackgroundForState(_ state: UIControlState, style: UIBarButtonItemStyle, barMetrics: UIBarMetrics) -> UIImage?
	func backBackgroundForState(_ state: UIControlState, barMetrics: UIBarMetrics) -> UIImage?
	
	func toolbarBackgroundForBarMetrics(metrics: UIBarMetrics) -> UIImage?
	
	var searchBackground: UIImage? { get }
	var searchFieldImage: UIImage? { get }
	func searchImageforIcon(_ icon: UISearchBarIcon, state: UIControlState) -> UIImage?
	func searchScopeButtonBackgroundForState(_ state: UIControlState) -> UIImage?
	var searchScopeButtonDivider: UIImage? { get }
	
	func segmentedBackgroundForState(_ state: UIControlState, barMetrics: UIBarMetrics) -> UIImage?
	func segmentedDividerForBarMetrics(_ barMetrics: UIBarMetrics) -> UIImage?
	
	var tableBackground: UIImage? { get }
	
	var onSwitchImage: UIImage? { get }
	var offSwitchImage: UIImage? { get }
	
	func sliderthumbForState( _ state: UIControlState) -> UIImage?
	var sliderMinTrack: UIImage? { get }
	var sliderMaxTrack: UIImage? { get }
	var speedSliderMinImage: UIImage? { get }
	var speedSliderMaxImage: UIImage? { get }

	var progressTrackImage: UIImage? { get }
	var progressProgressImage: UIImage? { get }

	func stepperBackgroundForState( _ state: UIControlState) -> UIImage?
	func stepperDividerForState(_ state: UIControlState) -> UIImage?
	var stepperIncrementImage: UIImage? { get }
	var stepperDecrementImage: UIImage? { get }

	func buttonBackgroundForState( _ state: UIControlState) -> UIImage?
	
	var tabBarBackground: UIImage? { get }
	var tabBarSelectionIndicator: UIImage? { get }
	// One of these must return a non-nil image for each tab:

	func imageFortab(_ tab: SSThemeTab) -> UIImage?
	func finishedImgeFortab(_ tab: SSThemeTab, selected: Bool) -> UIImage?

	func doorImageForState(_ state: UIControlState?) -> UIImage?

}

extension SSTheme {
	
	var mainColor: UIColor? { return nil }
	
	var highlightColor: UIColor? { return nil }
	
	var shadowColor: UIColor? { return nil }
	
	var backgroundColor: UIColor? { return nil }
	
	var baseTintColor: UIColor? { return nil }
	
	var accentTintColor: UIColor? { return nil }
	
	var switchThumbColor: UIColor? { return nil }
	
	var switchOnColor: UIColor? { return nil }
	
	var switchTintColor: UIColor? { return nil }
	
	var shadowOffset: CGSize { return CGSize.zero }
	
	var topShadow: UIImage?{ return nil }
	
	var bottomShadow: UIImage?{ return nil }
	
	func navigationBackgroundForBarMetrics(_ metrics: UIBarMetrics) -> UIImage? {
		return nil
	}
	
	func barButtonBackgroundForState(_ state: UIControlState, style: UIBarButtonItemStyle, barMetrics: UIBarMetrics) -> UIImage? {
		return nil
	}
	
	func backBackgroundForState(_ state: UIControlState, barMetrics: UIBarMetrics) -> UIImage? {
		return nil
	}
	
	func toolbarBackgroundForBarMetrics(metrics: UIBarMetrics) -> UIImage? {
		return nil
	}
	
	var searchBackground: UIImage? { return nil }
	
	var searchFieldImage: UIImage? { return nil }
	
	func searchImageforIcon(_ icon: UISearchBarIcon, state: UIControlState) -> UIImage? {
		return nil
	}
	
	func searchScopeButtonBackgroundForState(_ state: UIControlState) -> UIImage? {
		return nil
	}
	
	var searchScopeButtonDivider: UIImage? { return nil }
	
	func segmentedBackgroundForState(_ state: UIControlState, barMetrics: UIBarMetrics) -> UIImage? {
		return nil
	}
	
	func segmentedDividerForBarMetrics(_ barMetrics: UIBarMetrics) -> UIImage? {
		return nil
	}
	
	var tableBackground: UIImage? { return nil }
	
	var onSwitchImage: UIImage? { return nil }
	
	var offSwitchImage: UIImage? { return nil }
	
	func sliderthumbForState(_ state: UIControlState) -> UIImage? {
		return nil
	}
	
	var sliderMinTrack: UIImage? { return nil }
	
	var sliderMaxTrack: UIImage? { return nil }
	
	var speedSliderMinImage: UIImage? { return nil }
	
	var speedSliderMaxImage: UIImage? { return nil }
	
	var progressTrackImage: UIImage? { return nil }
	
	var progressProgressImage: UIImage? { return nil }
	
	func stepperBackgroundForState(_ state: UIControlState) -> UIImage? {
		return nil
	}
	
	func stepperDividerForState(_ state: UIControlState) -> UIImage? {
		return nil
	}
	
	var stepperIncrementImage: UIImage? { return nil }
	
	var stepperDecrementImage: UIImage? { return nil }
	
	func buttonBackgroundForState(_ state: UIControlState) -> UIImage? {
		return nil
	}
	
	var tabBarBackground: UIImage? { return nil }
	
	var tabBarSelectionIndicator: UIImage? { return nil }
	
	func imageFortab(_ tab: SSThemeTab) -> UIImage? {

		var name: String? = nil
		
		if tab == .door {
			name = "defaultDoorTab"
		}
		else if tab == .power {
			name = "defaultPowerTab"
		}
		else if tab == .controls {
			name = "defaultControlsTab"
		}
		
		return name != nil ? UIImage (named: name!) : nil
	}
	
	func finishedImgeFortab(_ tab: SSThemeTab, selected: Bool) -> UIImage? {
		return nil
	}
	
	func doorImageForState(_ state: UIControlState?) -> UIImage? {
		
		var name: String? = nil
		
		if state == .normal {
			name = "doorClosed"
		}
		else if state == .selected {
			name = "doorOpen"
		}
		
		if name != nil {
			var image = UIImage(named: name!)
			image = image?.resizableImage(withCapInsets: UIEdgeInsets(top: 16.0, left: 0.0, bottom: 15.0, right: 0.0))
			return image
		}
		else {
			return nil
		}
		
	}

}
