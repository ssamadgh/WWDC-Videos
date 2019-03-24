//
//  MainViewController.swift
//  SongMap_Swift
//
//  Created by Seyed Samad Gholamzadeh on 3/15/19.
//  Copyright © 2019 Seyed Samad Gholamzadeh. All rights reserved.
//
/*
Abstract:
This controller manages the primary view. It is responsible for monitoring changes to the managed object context, adding additional annotations, and returning annotation views to the map view for display.
*/

import UIKit
import CoreData
import MapKit

class MainViewController: UIViewController, FlipsideViewControllerDelegate, MKMapViewDelegate {

	let launchedPreviouslyKey = "LaunchedPreviously"
	let annotationViewID = "SongLocation"
	
	@IBOutlet weak var mapView: MKMapView!
	
	var context: NSManagedObjectContext! {
		willSet {
			// we must remember to remove our old observer if we have one
			if context != nil {
				NotificationCenter.default.removeObserver(self, name: nil, object: self.context)
			}
			
			// register the new observer, unless assigning nil
			if newValue != nil {
				NotificationCenter.default.addObserver(self, selector: #selector(managedObjectContextDidSave(_:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: context)
			}
			
		}
	}

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		var newRegion = MKCoordinateRegion()
		newRegion.center.latitude = 37.332170
		newRegion.center.longitude = -122.030598
		newRegion.span.latitudeDelta = 0.014203
		newRegion.span.longitudeDelta = 0.013741
		self.mapView.setRegion(newRegion, animated: false)
		
		do {
			let newAnnotations = try SongLocation.fetchRecentLimit(20, in: context)
			self.addAnnotations(newAnnotations)

		} catch {
			print("error is \(error.localizedDescription)")
		}
    }
	
	// Implement viewWillAppear: to do additional setup before the view is presented. You might, for example, fetch objects from the managed object context if necessary.
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		if !UserDefaults.standard.bool(forKey: launchedPreviouslyKey) {
			self.perform(#selector(showInfo(_:)), with: self, afterDelay: 1.0)
		}
	}
	
	func flipsideViewControllerDidFinish(_ controller: FlipsideViewController) {
		UserDefaults.standard.set(true, forKey: launchedPreviouslyKey)
		self.dismiss(animated: true, completion: nil)
	}
    

	@IBAction func showInfo(_ sender: Any) {
		let controller = FlipsideViewController.init(nibName: "FlipsideView", bundle: nil)
		controller.delegate = self
		controller.modalTransitionStyle = UIModalTransitionStyle.flipHorizontal
		self.present(controller, animated: true, completion: nil)
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
	
	
	//MARK: - MKMapViewDelegate
	// mapView:viewForAnnotation: provides the view for each annotation.
	// This method may be called for all or some of the added annotations.
	// For MapKit provided annotations (eg. MKUserLocation) return nil to use the MapKit provided annotation view.
	func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
		
		var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationViewID)
		
		if annotationView == nil {
			annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationViewID)
			annotationView!.canShowCallout = true
		}
		

		var albumIcon: UIImage?
		
		if ((annotation as? SongLocation)?.song) != nil {
			albumIcon = (annotation as? SongLocation)?.artworkImage(withSize: CGSize(width: 32.0, height: 32.0))
			if albumIcon == nil {
				albumIcon = UIImage(named: "noArtwork")
			}
		}
		else {
			albumIcon = UIImage(named: "noMedia")
		}
		
		annotationView?.image = albumIcon
		
		return annotationView;
	}
	
	@objc func managedObjectContextDidSave(_ notification: NSNotification) {
		guard let info = notification.userInfo else { return }
		
		if let deleted = (info[NSDeletedObjectsKey] as? NSSet)?.allObjects as? [MKAnnotation] {
			self.mapView.removeAnnotations(deleted)
		}
		
		if let inserted = (info[NSInsertedObjectsKey] as? NSSet)?.allObjects as? [MKAnnotation] {
			self.mapView.addAnnotations(inserted)
		}
	}
	
	func addAnnotations(_ annotations: [MKAnnotation]) {
		var newRegion = MKCoordinateRegion()
		newRegion.span.latitudeDelta = 0.014203
		newRegion.span.longitudeDelta = 0.013741

		if !annotations.isEmpty {
			guard let sl = annotations.first as? SongLocation else { return }
			newRegion.center = sl.location!.coordinate
			self.mapView.setRegion(newRegion, animated: true)
			self.mapView.addAnnotations(annotations)
		}
	}
	
	
}
