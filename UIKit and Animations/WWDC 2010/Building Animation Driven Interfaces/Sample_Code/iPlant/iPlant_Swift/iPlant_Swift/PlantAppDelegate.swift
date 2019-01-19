//
//  AppDelegate.swift
//  iPlant_Swift
//
//  Created by Seyed Samad Gholamzadeh on 3/6/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

@UIApplicationMain
class PlantAppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?
	var viewController: PlantViewController!
	var plantFrontView: PlantCareView!
	var plantBackView: UIView!


	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		// Override point for customization after application launch.
		self.window = UIWindow(frame: UIScreen.main.bounds)

		self.viewController = PlantViewController()
//		self.viewController.view.backgroundColor = UIColor.purple
		self.setupBackView()
		plantFrontView = PlantCareView(frame: self.viewController.view.bounds)
		self.viewController.view.addSubview(self.plantFrontView)

		// Set this so that the background of the transition is black
		window?.backgroundColor = UIColor.black
		
		window?.rootViewController = viewController
		window?.makeKeyAndVisible()
		
		return true
	}

	
	/*
	Show the back of the app
	*/
	@objc func showBack(_ sender: Any) {
		UIView.transition(from: self.plantFrontView, to: self.plantBackView, duration: 1.0, options: .transitionFlipFromLeft, completion: nil)
	}
	
	/*
	Show the front of the app
	*/
	@objc func showFront(_ sender: Any) {
		// Remember: In your apps use the transitionFromView:toView: API symmetrically. The below use of the transitionWithView: API is simply illustrative.
		plantBackView.removeFromSuperview()
		viewController.view.addSubview(plantFrontView)
		
		UIView.transition(with: viewController.view, duration: 1.0, options: .transitionFlipFromRight, animations: nil, completion: nil)
	}
	
	func setupBackView() {
		
		let backgroundColor = UIColor.lightGray
		let bounds = viewController.view.bounds
		
		plantBackView = UIView(frame: bounds)
		plantBackView.backgroundColor = backgroundColor
		
		let doneButton = UIButton(type: .roundedRect)
		doneButton.frame = CGRect(x: 20, y: 20, width: 100, height: 45)
		doneButton.setTitle("Done", for: .normal)
		doneButton.addTarget(self, action: #selector(showFront(_:)), for: .touchUpInside)
		plantBackView.addSubview(doneButton)
		
		let infoLabel = UILabel()
		infoLabel.bounds = CGRect(x: 0, y: 0, width: 320, height: 320)
		infoLabel.center = CGPoint(x: bounds.midX, y: bounds.midY)
		infoLabel.text = "iPlant, WWDC 2010"
		infoLabel.font = UIFont(name: "Helviteca", size: 25)
		infoLabel.textAlignment = .center
		infoLabel.backgroundColor = backgroundColor
		plantBackView.addSubview(infoLabel)
	}


}

