/*
  LazyTableAppDelegate.swift
  LazyTable

  Created by Seyed Samad Gholamzadeh on 6/25/18.
  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.


Abstract: Application delegate for the LazyTableImage sample.
It also downloads in the background the "Top paid iPhone apps" RSS feed using URLSession.
*/


import UIKit

// This framework was imported so we could use the kCFURLErrorNotConnectedToInternet error code.
import CFNetwork

let TopPaidAppsFeed =
"http://phobos.apple.com/WebObjects/MZStoreServices.woa/ws/RSS/toppaidapplications/limit=75/xml";


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?
	var rootViewController: RootViewController!
	var appRecords: [AppRecord]!
	var queue: OperationQueue!
	
	// -------------------------------------------------------------------------------
	//	applicationDidFinishLaunching:application
	// -------------------------------------------------------------------------------
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

		let nav = window!.rootViewController as! UINavigationController
		self.rootViewController = nav.topViewController as! RootViewController
		self.appRecords = []
		// Initialize the array of app records and pass a reference to that list to our root view controller
		
		let urlRequest = URLRequest(url: URL(string: TopPaidAppsFeed)!)
		
		// Test the validity of the connection object. The most likely reason for the connection object
		// to be nil is a malformed URL, which is a programmatic error easily detected during development
		// If the URL is more dynamic, then you should implement a more flexible validation technique, and
		// be able to both recover from errors and communicate problems to the user in an unobtrusive manner.
		//
		let task = URLSession.shared.dataTask(with: urlRequest) { (data, responce, error) in
			
			guard error == nil else {
				self.handleError(error!)
				return
			}
			
			
			// create the queue to run our ParseOperation

			self.queue = OperationQueue()
			
			// create an ParseOperation (NSOperation subclass) to parse the RSS feed data so that the UI is not blocked
			// "ownership of appListData has been transferred to the parse operation and should no longer be
			// referenced in this thread.
			//
			let parser = ParseOperation(data: data!, completionHandler: { (appList) in
				DispatchQueue.main.async {
					self.handleLoadedApps(appList)
				}
				self.queue = nil
			})
			
			parser.errorHandler = { error in
				DispatchQueue.main.async {
					self.handleError(error)
				}
			}
			
			self.queue.addOperation(parser)  // this will start the "ParseOperation"

		}
		
		UIApplication.shared.isNetworkActivityIndicatorVisible = true
		task.resume()
		
		return true
	}
	
	// -------------------------------------------------------------------------------
	//	handleLoadedApps:notif
	// -------------------------------------------------------------------------------
	func handleLoadedApps(_ loadedApps: [AppRecord]) {
		self.appRecords.append(contentsOf: loadedApps)
		rootViewController.entries = self.appRecords
		// tell our table view to reload its data, now that parsing has completed
		self.rootViewController.tableView.reloadData()
	}
	
	// -------------------------------------------------------------------------------
	//	handleError:error
	// -------------------------------------------------------------------------------
	func handleError(_ error: Error) {
		let errorMessage = error.localizedDescription
		let alertView = UIAlertController(title: "Cannot Show Top Paid Apps", message: errorMessage, preferredStyle: .alert)
		alertView.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
		self.rootViewController.present(alertView, animated: true, completion: nil)
	}
	
}

