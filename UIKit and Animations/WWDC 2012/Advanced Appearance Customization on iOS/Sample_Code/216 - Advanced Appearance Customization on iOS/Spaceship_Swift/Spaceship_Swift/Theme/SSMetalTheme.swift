//
//  SSMetalTheme.swift
//  Spaceship_Swift
//
//  Created by Seyed Samad Gholamzadeh on 4/27/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

struct SSMetalTheme: SSTheme {
	
	var mainColor: UIColor? { return UIColor(white: 0.2, alpha: 1.0) }
	
	var highlightColor: UIColor? { return UIColor(white: 0.9, alpha: 1.0) }
	
	var shadowColor: UIColor? { return UIColor(white: 1.0, alpha: 1.0) }
	
	var backgroundColor: UIColor? { return UIColor(white: 0.85, alpha: 1.0) }
	
	var switchThumbColor: UIColor? { return UIColor(white: 0.75, alpha: 1.0) }
	
	var switchOnColor: UIColor? { return UIColor(white: 0.25, alpha: 1.0) }
	
	var switchTintColor: UIColor? { return UIColor(white: 0.85, alpha: 1.0) }
	
	var shadowOffset: CGSize { return CGSize(width: 0.0, height: 1.0) }
	
	var topShadow: UIImage?{ return UIImage(named: "topShadow") }
	
	var bottomShadow: UIImage?{ return UIImage(named: "bottomShadow") }
	
	func navigationBackgroundForBarMetrics(_ metrics: UIBarMetrics) -> UIImage? {
		var name = "navigationBackground"
		
		if metrics == UIBarMetrics.compact || metrics == UIBarMetrics.compactPrompt {
			name += "Landscape"
		}
		
		var image = UIImage(named: name)
		image = image?.resizableImage(withCapInsets: UIEdgeInsets(top: 0.0, left: 8.0, bottom: 0.0, right: 8.0), resizingMode: .stretch)
		return image
	}
	
	func barButtonBackgroundForState(_ state: UIControlState, style: UIBarButtonItemStyle, barMetrics: UIBarMetrics) -> UIImage? {

		var name = "barButton"
		
		if style == .done {
			name += "Done"
		}
		
		if barMetrics == .compact || barMetrics == UIBarMetrics.compactPrompt {
			name += "Landscape"
		}
		
		if state == .highlighted {
			name += "Highlighted"
		}
		
		var image = UIImage(named: name)
		image = image?.resizableImage(withCapInsets: UIEdgeInsets(top: 0.0, left: 13.0, bottom: 0.0, right: 13.0))
		return image
	}
	
	func backBackgroundForState(_ state: UIControlState, barMetrics: UIBarMetrics) -> UIImage? {

		var name = "backButton"
		if barMetrics == .compact || barMetrics == UIBarMetrics.compactPrompt {
			name += "Landscape"
		}
		
		if state == .highlighted {
			name += "Highlighted"
		}
		var image = UIImage(named: name)
		image = image?.resizableImage(withCapInsets: UIEdgeInsets(top: 0.0, left: 21.0, bottom: 0.0, right: 13.0))
		return image
	}
	
	func toolbarBackgroundForBarMetrics(_ barMetrics: UIBarMetrics) -> UIImage? {
		var name = "toolbarBackground"
		if barMetrics == .compact || barMetrics == UIBarMetrics.compactPrompt {
			name += "Landscape"
		}
		
		var image = UIImage(named: name)
		image = image?.resizableImage(withCapInsets: UIEdgeInsets(top: 0.0, left: 8.0, bottom: 0.0, right: 8.0))
		return image
	}
	
	var searchBackground: UIImage? { return UIImage(named: "searchBackground") }
	
	var searchFieldImage: UIImage? {
		var image = UIImage(named: "searchField")
		image = image?.resizableImage(withCapInsets: UIEdgeInsets(top: 0.0, left: 16.0, bottom: 0.0, right: 16.0))
		return image

	}
	
	func searchImageforIcon(_ icon: UISearchBarIcon, state: UIControlState) -> UIImage? {

		var name: String? = nil
		
		if icon == .search {
			name = "searchIconSearch"
		}
		else if icon == .clear {
			name = "searchIconClear"
			
			if state == .highlighted {
				name! += "Highlighted"
			}

		}
		
		return name != nil ? UIImage(named: name!) : nil
	}
	
	func searchScopeButtonBackgroundForState(_ state: UIControlState) -> UIImage? {
		var name = "searchScopeButton"
		if state == .selected {
			name += "Selected"
		}
		
		var image = UIImage(named: name)
		image = image?.resizableImage(withCapInsets: UIEdgeInsets(top: 0.0, left: 13.0, bottom: 0.0, right: 13.0))
		return image
	}
	
	var searchScopeButtonDivider: UIImage? { return UIImage(named: "searchScopeDivider") }
	
	func segmentedBackgroundForState(_ state: UIControlState, barMetrics: UIBarMetrics) -> UIImage? {

		var name = "segmentedBackground"
		if barMetrics == .compact || barMetrics == UIBarMetrics.compactPrompt {
			name += "Landscape"
		}
		
		if state == .selected {
			name += "Selected"
		}
		var image = UIImage(named: name)
		image = image?.resizableImage(withCapInsets: UIEdgeInsets(top: 0.0, left: 13.0, bottom: 0.0, right: 13.0))
		return image
	}
	
	func segmentedDividerForBarMetrics(_ barMetrics: UIBarMetrics) -> UIImage? {
		var name = "segmentedDivider"
		if barMetrics == .compact || barMetrics == UIBarMetrics.compactPrompt {
			name += "Landscape"
		}
		let image = UIImage(named: name)
		return image
	}
	
	var tableBackground: UIImage? {
		var image = UIImage(named: "tableBackground")
		image = image?.resizableImage(withCapInsets: UIEdgeInsets.zero)
		return image
	}
	
	var onSwitchImage: UIImage? { return UIImage(named: "onSwitch") }
	
	var offSwitchImage: UIImage? { return UIImage(named: "offSwitch") }
	
	func sliderthumbForState(_ state: UIControlState) -> UIImage? {
		var name = "sliderThumb"
		if state == .highlighted {
			name += "Highlighted"
		}
		let image = UIImage(named: name)
		return image
	}
	
	var sliderMinTrack: UIImage? {
	
		var image = UIImage(named: "sliderMinTrack")
		image = image?.resizableImage(withCapInsets: UIEdgeInsets(top: 0.0, left: 7.0, bottom: 0.0, right: 7.0))
		return image
	}
	
	var sliderMaxTrack: UIImage? {
		var image = UIImage(named: "sliderMaxTrack")
		image = image?.resizableImage(withCapInsets: UIEdgeInsets(top: 0.0, left: 7.0, bottom: 0.0, right: 7.0))
		return image
	}
	
	var speedSliderMinImage: UIImage? { return UIImage(named: "slowShip") }
	
	var speedSliderMaxImage: UIImage? { return UIImage(named: "fastShip") }
	
	var progressTrackImage: UIImage? {
		
		var image = UIImage(named: "progressTrack")
		image = image?.resizableImage(withCapInsets: UIEdgeInsets(top: 0.0, left: 7.0, bottom: 0.0, right: 7.0))
		return image

	}
	
	var progressProgressImage: UIImage? {
		
		var image = UIImage(named: "progressProgress")
		image = image?.resizableImage(withCapInsets: UIEdgeInsets(top: 0.0, left: 7.0, bottom: 0.0, right: 7.0))
		return image
	
	}
	
	func stepperBackgroundForState(_ state: UIControlState) -> UIImage? {

		var name = "stepperBackground"
		if state == .highlighted {
			name += "Highlighted"
		}
		else if state == .disabled {
			name += "Disabled"
		}

		var image = UIImage(named: name)
		image = image?.resizableImage(withCapInsets: UIEdgeInsets(top: 0.0, left: 13.0, bottom: 0.0, right: 13.0))
		return image
	}
	
	func stepperDividerForState(_ state: UIControlState) -> UIImage? {
		var name = "stepperDivider"
		if state == .highlighted {
			name += "Highlighted"
		}
		else if state == .disabled {
			name += "Disabled"
		}
		
		let image = UIImage(named: name)
		return image
	}
	
	var stepperIncrementImage: UIImage? { return UIImage(named: "stepperIncrement") }
	
	var stepperDecrementImage: UIImage? { return UIImage(named: "stepperDecrement") }
	
	func buttonBackgroundForState(_ state: UIControlState) -> UIImage? {

		var name = "button"
		if state == .highlighted {
			name += "Highlighted"
		}
		else if state == .disabled {
			name += "Disabled"
		}
		
		var image = UIImage(named: name)
		image = image?.resizableImage(withCapInsets: UIEdgeInsets(top: 0.0, left: 16.0, bottom: 0.0, right: 16.0))
		return image
	}
	
	var tabBarBackground: UIImage? { return UIImage(named: "tabBarBackground") }
	
	var tabBarSelectionIndicator: UIImage? { return UIImage(named: "tabBarSelectionIndicator") }
	
	func imageFortab(_ tab: SSThemeTab) -> UIImage? {
		
		return nil
	}
	
	func finishedImgeFortab(_ tab: SSThemeTab, selected: Bool) -> UIImage? {
		
		var name: String? = nil
		
		if tab == .door {
			name = "doorTab"
		}
		else if tab == .power {
			name = "powerTab"
		}
		else if tab == .controls {
			name = "controlsTab"
		}

		if selected {
			name! += "Selected"
		}
		
		var image: UIImage?
		if name != nil {
			image = UIImage(named: name!)
			image = image?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
		}
		return image
	}
	
	func doorImageForState(_ state: UIControlState?) -> UIImage? {
		
		var name: String!
		
		if state != nil, state == .disabled {
			name = "doorDisabled"
		}
		else {
			if state != nil, state == .selected {
				name = "doorOpen"
			}
			else {
				name = "doorClosed"
			}
			if state != nil, state == .highlighted {
				name! += "Highlighted"
			}
		}
		
		var image = UIImage(named: name)
		image = image?.resizableImage(withCapInsets: UIEdgeInsets(top: 16.0, left: 0.0, bottom: 15.0, right: 0.0))
		return image
	}

}
