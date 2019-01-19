//
//  SSThemeManager.swift
//  Spaceship_Swift
//
//  Created by Seyed Samad Gholamzadeh on 4/27/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

struct SSThemeManager {
	
	static var shared: SSTheme = {
		// Create and return the theme:
		var sharedTheme: SSTheme
		//        sharedTheme = SSDefaultTheme()
		//        sharedTheme = SSTintedTheme()
		sharedTheme = SSMetalTheme()
		
		return sharedTheme
	}()
	
	static func customizeAppAppearance() {
		let theme = self.shared
		
		let navigationBarAppearance = UINavigationBar.appearance()
		navigationBarAppearance.setBackgroundImage(theme.navigationBackgroundForBarMetrics(.default), for: .default)
		navigationBarAppearance.setBackgroundImage(theme.navigationBackgroundForBarMetrics(.defaultPrompt), for: .defaultPrompt)
		navigationBarAppearance.setBackgroundImage(theme.navigationBackgroundForBarMetrics(.compact), for: .compact)
		navigationBarAppearance.setBackgroundImage(theme.navigationBackgroundForBarMetrics(.compactPrompt), for: .compactPrompt)
		navigationBarAppearance.shadowImage = theme.topShadow
		
		let barButtonItemAppearance = UIBarButtonItem.appearance()
		barButtonItemAppearance.setBackgroundImage(theme.barButtonBackgroundForState(.normal, style: .plain, barMetrics: .default), for: .normal, barMetrics: .default)
		barButtonItemAppearance.setBackgroundImage(theme.barButtonBackgroundForState(.highlighted, style: .plain, barMetrics: .default), for: .highlighted, barMetrics: .default)
		barButtonItemAppearance.setBackgroundImage(theme.barButtonBackgroundForState(.normal, style: .plain, barMetrics: .compact), for: .normal, barMetrics: .compact)
		barButtonItemAppearance.setBackgroundImage(theme.barButtonBackgroundForState(.highlighted, style: .plain, barMetrics: .compact), for: .highlighted, barMetrics: .compact)

		barButtonItemAppearance.setBackgroundImage(theme.barButtonBackgroundForState(.normal, style: .done, barMetrics: .default), for: .normal, barMetrics: .default)
		barButtonItemAppearance.setBackgroundImage(theme.barButtonBackgroundForState(.highlighted, style: .done, barMetrics: .default), for: .highlighted, barMetrics: .default)
		barButtonItemAppearance.setBackgroundImage(theme.barButtonBackgroundForState(.normal, style: .done, barMetrics: .compact), for: .normal, barMetrics: .compact)
		barButtonItemAppearance.setBackgroundImage(theme.barButtonBackgroundForState(.highlighted, style: .done, barMetrics: .compact), for: .highlighted, barMetrics: .compact)

		barButtonItemAppearance.setBackButtonBackgroundImage(theme.backBackgroundForState(.normal, barMetrics: .default), for: .normal, barMetrics: .default)
		barButtonItemAppearance.setBackButtonBackgroundImage(theme.backBackgroundForState(.highlighted, barMetrics: .default), for: .highlighted, barMetrics: .default)
		barButtonItemAppearance.setBackButtonBackgroundImage(theme.backBackgroundForState(.normal, barMetrics: .compact), for: .normal, barMetrics: .compact)
		barButtonItemAppearance.setBackButtonBackgroundImage(theme.backBackgroundForState(.highlighted, barMetrics: .compact), for: .highlighted, barMetrics: .compact)
		
		let segmentedAppearance = UISegmentedControl.appearance()
		segmentedAppearance.setBackgroundImage(theme.segmentedBackgroundForState(.normal, barMetrics: .default), for: .normal, barMetrics: .default)
		segmentedAppearance.setBackgroundImage(theme.segmentedBackgroundForState(.selected, barMetrics: .default), for: .selected, barMetrics: .default)
		segmentedAppearance.setBackgroundImage(theme.segmentedBackgroundForState(.normal, barMetrics: .compact), for: .normal, barMetrics: .compact)
		segmentedAppearance.setBackgroundImage(theme.segmentedBackgroundForState(.normal, barMetrics: .default), for: .normal, barMetrics: .default)

		segmentedAppearance.setDividerImage(theme.segmentedDividerForBarMetrics(.default), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
		segmentedAppearance.setDividerImage(theme.segmentedDividerForBarMetrics(.compact), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .compact)

		let tabBarAppearnance = UITabBar.appearance()
		tabBarAppearnance.backgroundImage = theme.tabBarBackground
		tabBarAppearnance.selectionIndicatorImage = theme.tabBarSelectionIndicator
		tabBarAppearnance.shadowImage = theme.bottomShadow
		
		let toolbarAppearance = UIToolbar.appearance()
		toolbarAppearance.setBackgroundImage(theme.toolbarBackgroundForBarMetrics(metrics: .default), forToolbarPosition: .any, barMetrics: .default)
		toolbarAppearance.setBackgroundImage(theme.toolbarBackgroundForBarMetrics(metrics: .compact), forToolbarPosition: .any, barMetrics: .compact)
		toolbarAppearance.setShadowImage(theme.bottomShadow, forToolbarPosition: .any)

		let searchBarAppearance = UISearchBar.appearance()
		searchBarAppearance.backgroundImage = theme.searchBackground
		searchBarAppearance.setSearchFieldBackgroundImage(theme.searchFieldImage, for: .normal)
		searchBarAppearance.setImage(theme.searchImageforIcon(.search, state: .normal), for: .search, state: .normal)
		searchBarAppearance.setImage(theme.searchImageforIcon(.clear, state: .normal), for: .clear, state: .normal)
		
		searchBarAppearance.setImage(theme.searchImageforIcon(.clear, state: .highlighted), for: .clear, state: .highlighted)

		searchBarAppearance.scopeBarBackgroundImage = theme.searchBackground
		searchBarAppearance.setScopeBarButtonBackgroundImage(theme.searchScopeButtonBackgroundForState(.normal), for: .normal)
		searchBarAppearance.setScopeBarButtonBackgroundImage(theme.searchScopeButtonBackgroundForState(.selected), for: .selected)
		searchBarAppearance.setScopeBarButtonDividerImage(theme.searchScopeButtonDivider, forLeftSegmentState: .normal, rightSegmentState: .normal)
		
		let sliderAppearance = UISlider.appearance()
		sliderAppearance.setThumbImage(theme.sliderthumbForState(.normal), for: .normal)
		sliderAppearance.setThumbImage(theme.sliderthumbForState(.highlighted), for: .highlighted)
		sliderAppearance.setMinimumTrackImage(theme.sliderMinTrack, for: .normal)
		sliderAppearance.setMaximumTrackImage(theme.sliderMaxTrack, for: .normal)

		let progressAppearance = UIProgressView.appearance()
		progressAppearance.trackImage = theme.progressTrackImage
		progressAppearance.progressImage = theme.progressProgressImage
		
		let switchAppearance = UISwitch.appearance()
		switchAppearance.onImage = theme.onSwitchImage
		switchAppearance.offImage = theme.offSwitchImage
		switchAppearance.tintColor = theme.switchTintColor
		switchAppearance.onTintColor = theme.switchOnColor
		switchAppearance.thumbTintColor = theme.switchThumbColor
		
		let stepperAppearance = UIStepper.appearance()
		stepperAppearance.setBackgroundImage(theme.stepperBackgroundForState(.normal), for: .normal)
		stepperAppearance.setBackgroundImage(theme.stepperBackgroundForState(.highlighted), for: .highlighted)
		stepperAppearance.setBackgroundImage(theme.stepperBackgroundForState(.disabled), for: .disabled)
		stepperAppearance.setDividerImage(theme.stepperDividerForState(.normal), forLeftSegmentState: .normal, rightSegmentState: .normal)
		stepperAppearance.setDividerImage(theme.stepperDividerForState(.highlighted), forLeftSegmentState: .highlighted, rightSegmentState: .normal)
		stepperAppearance.setDividerImage(theme.stepperDividerForState(.highlighted), forLeftSegmentState: .normal, rightSegmentState: .highlighted)
		stepperAppearance.setIncrementImage(theme.stepperIncrementImage, for: .normal)
		stepperAppearance.setIncrementImage(theme.stepperDecrementImage, for: .normal)

		var titleTextAttributes: [NSAttributedStringKey : Any] = [:]
		var stringTitleTextAttributes: [String : Any] = [:]

		let mainColor = theme.mainColor
		if (mainColor != nil) {
			titleTextAttributes[NSAttributedStringKey.foregroundColor] = mainColor
			stringTitleTextAttributes[NSAttributedStringKey.foregroundColor.rawValue] = mainColor

		}
		let shadowColor = theme.shadowColor
		if (shadowColor != nil) {
			let shadowOffset = theme.shadowOffset
			let shadow = NSShadow()
			shadow.shadowColor = shadowColor
			shadow.shadowOffset = shadowOffset
			titleTextAttributes[NSAttributedStringKey.shadow] = shadow
			stringTitleTextAttributes[NSAttributedStringKey.shadow.rawValue] = shadow
		}
		navigationBarAppearance.titleTextAttributes = titleTextAttributes
		barButtonItemAppearance.setTitleTextAttributes(titleTextAttributes, for: .normal)
		barButtonItemAppearance.setTitleTextAttributes(titleTextAttributes, for: .highlighted)
		segmentedAppearance.setTitleTextAttributes(titleTextAttributes, for: .normal)
		searchBarAppearance.setScopeBarButtonTitleTextAttributes(stringTitleTextAttributes, for: .normal)
		
		let headerLabelAppearance = UILabel.appearance(whenContainedInInstancesOf: [UITableViewHeaderFooterView.self])
		let accentTintColor = theme.accentTintColor
		if accentTintColor != nil {
			sliderAppearance.maximumTrackTintColor = accentTintColor
			progressAppearance.trackTintColor = accentTintColor
			let toolbarBarButtonItemAppearance = UIBarButtonItem.appearance(whenContainedInInstancesOf: [UIToolbar.self])
			toolbarBarButtonItemAppearance.tintColor = accentTintColor
			tabBarAppearnance.tintColor = accentTintColor
		}
		
		let baseTintColor = theme.baseTintColor
		if baseTintColor != nil {
			navigationBarAppearance.tintColor = baseTintColor
			barButtonItemAppearance.tintColor = baseTintColor
			segmentedAppearance.tintColor = baseTintColor
			tabBarAppearnance.tintColor = baseTintColor
			toolbarAppearance.tintColor = baseTintColor
			searchBarAppearance.tintColor = baseTintColor
			sliderAppearance.thumbTintColor = baseTintColor
			sliderAppearance.minimumTrackTintColor = baseTintColor
			progressAppearance.tintColor = baseTintColor
		}
		else if mainColor != nil {
			headerLabelAppearance.textColor = mainColor
		}		
	}
	
	static func customize( _ view: UIView) {
		let theme = shared
		if let backgroundColor = theme.backgroundColor {
			view.backgroundColor = backgroundColor
		}
	}
	
	static func customize( _ tableView: UITableView) {
		let theme = shared
		if let backgroundImage = theme.tableBackground {
			let background = UIImageView(image: backgroundImage)
			tableView.backgroundView = background
		}
		else if let backgroundColor = theme.backgroundColor {
			tableView.backgroundView = nil
			tableView.backgroundColor = backgroundColor
		}
	}
	
	static func customize(_ tabBarItem: UITabBarItem, for tab: SSThemeTab) {
		let theme = shared
		if let image = theme.imageFortab(tab) {
			// If we have a regular image, set that
			tabBarItem.image = image
		}
		else {
			// Otherwise, set the finished images
			let selectedImage = theme.finishedImgeFortab(tab, selected: true)
			let unSelectedImage = theme.finishedImgeFortab(tab, selected: false)
			tabBarItem.image = unSelectedImage
			tabBarItem.selectedImage = selectedImage
		}
	}
	
	static func customizeDoorButton( button: UIButton) {
		let theme = shared
		button.setBackgroundImage(theme.doorImageForState(.disabled), for: .disabled)
		button.setBackgroundImage(theme.doorImageForState(.normal), for: .normal)
		let higlightedImage = theme.doorImageForState(.highlighted)
		let selectedImage = theme.doorImageForState(.selected)
		if higlightedImage != nil && selectedImage != nil {
			button.setBackgroundImage(higlightedImage, for: .highlighted)
			button.setBackgroundImage(selectedImage, for: .selected)
		}
		else if higlightedImage != nil {
			button.setBackgroundImage(higlightedImage, for: .highlighted)
			button.setBackgroundImage(higlightedImage, for: .selected)
		}
		else {
			button.setBackgroundImage(selectedImage, for: .highlighted)
			button.setBackgroundImage(selectedImage, for: .selected)
		}
	}
	
	
}
