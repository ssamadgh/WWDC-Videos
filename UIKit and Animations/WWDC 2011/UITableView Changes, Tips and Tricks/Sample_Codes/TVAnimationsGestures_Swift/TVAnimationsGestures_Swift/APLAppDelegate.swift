//
//  AppDelegate.swift
//  TVAnimationsGestures_Swift
//
//  Created by Seyed Samad Gholamzadeh on 6/22/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit

@UIApplicationMain
class APLAppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?
	lazy var plays: Array<APLPlay> = {
		
//		var plays: [APLPlay] = []
		
		let url = Bundle.main.url(forResource: "PlaysAndQuotations", withExtension: "plist")!
		
		let data = try! Data(contentsOf: url)
		let decoder = PropertyListDecoder()
		let plays = try! decoder.decode([APLPlay].self, from: data)
		
//		let playDictionariesArray = Array(NSArray(contentsOf: url)!) as! [[String: Any]]
//
//		for playDictionary in playDictionariesArray {
//			var play = APLPlay()
//			play.name = playDictionary["playName"] as! String
//			let quotationDictionaries = playDictionary["quotations"] as! [[String: Any]]
//			var quotations: Array<APLQuotation> = []
//			
//			for quotationDictionary in quotationDictionaries {
//				let quotation = APLQuotation()
//				quotation.setValuesForKeys(quotationDictionary)
//				
//				quotations.append(quotation)
//			}
//			
////			play.quotations = quotations
//			
//			plays.append(play)
//		}
		
		return plays
	}()

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

		// pass the plays to the table view controller
		let navigationController = self.window?.rootViewController as! UINavigationController
		let tableViewController = navigationController.topViewController as! APLTableViewController
		tableViewController.plays = self.plays

		return true
	}


}

