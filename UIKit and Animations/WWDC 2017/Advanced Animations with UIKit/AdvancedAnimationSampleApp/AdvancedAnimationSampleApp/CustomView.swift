//
//  ContainerView.swift
//  AdvancedAnimationSampleApp
//
//  Created by Seyed Samad Gholamzadeh on 11/15/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit


class CustomView: UIView {
	
	override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
		let superViewPoint = self.convert(point, to: superview)
		let layerPoint = layer.presentation()?.convert(superViewPoint, from: superview?.layer) ?? point
		
		return super.hitTest(layerPoint, with: event)
	}
	
}
