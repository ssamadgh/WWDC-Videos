//
//  ViewController.swift
//  Reminders_Swift
//
//  Created by Seyed Samad Gholamzadeh on 3/18/19.
//  Copyright © 2019 Seyed Samad Gholamzadeh. All rights reserved.
//
/*
Abstract:
The main view controller consisting primarily of an MKMapView overlaid with annotations
*/

import UIKit
import CoreLocation
import MapKit

class RemindersViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, ReminderAnnotationDetailDelegate {
	
	let kReminderAnnotationId = "ReminderAnnotation"
	
	@IBOutlet weak var mapView: MKMapView!
	@IBOutlet weak var locateUserButton: UIBarButtonItem!
	@IBOutlet weak var showListButton: UIBarButtonItem!
	@IBOutlet weak var addRegionButton: UIBarButtonItem!
	
	var isDraggingPin: Bool = false
	var goToUserLocation: Bool!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		
		if !CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
			self.addRegionButton.isEnabled = false
			
			let alertController = UIAlertController(title: "Unsupported", message: "Sorry, this device cannot create GeoFence reminders.", preferredStyle: .alert)
			alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
			self.present(alertController, animated: true, completion: nil)
			
		}
		
		
		goToUserLocation = true
		
		mapView.delegate = self
		mapView.showsUserLocation = true
		
		let regions = RegionManager.shared.regions
		
		for region in regions {
			let reminder = ReminderAnnotation(region: region)
			self.addAnnotation(reminder)
		}
		
	}
	
	override func didReceiveMemoryWarning() {
		print("didReceiveMemoryWarning")
	}
	
	deinit {
		self.mapView.removeAnnotations(self.mapView.annotations)
		self.mapView.removeOverlays(self.mapView.overlays)
	}
	
	@IBAction func locateUser(_ sender: Any) {
		mapView.showsUserLocation = false
		goToUserLocation = true
		mapView.showsUserLocation = true
	}
	
	@IBAction func addRegion(_ sender: Any) {
		let reminder = ReminderAnnotation.reminder(with: self.mapView.centerCoordinate)
		self.addAnnotation(reminder)
		RegionManager.shared.addRegion(reminder.region)
	}
	
	func addAnnotation(_ annotation: MKAnnotation) {
		// Reminders must have unique titles, remove any existing ones with the same title
		var replaced: [ReminderAnnotation] = []
		
		self.mapView.annotations.forEach { (a) in
			if let a = a as? ReminderAnnotation {
				if a.title == annotation.title {
					replaced.append(a)
				}
			}
		}
		
		self.mapView.removeAnnotations(replaced)
		self.mapView.removeOverlays(replaced)
		self.mapView.addAnnotation(annotation)
		
		if let annotation = annotation as? ReminderAnnotation {
			self.mapView.addOverlay(annotation)
		}
		
	}
	
	func removeAnnotation(_ annotation: MKAnnotation) {
		self.mapView.removeAnnotation(annotation)
		if let annotation = annotation as? ReminderAnnotation {
			self.mapView.removeOverlay(annotation)
		}
	}
	
	func reminderAnnotationDetailDidFinish(_ controller: ReminderAnnotationDetail, withAction action: ReminderAnnotationDetailAction) {
		switch action {
		case .save:
			RegionManager.shared.removeRegion(controller.originalRegion)
			RegionManager.shared.addRegion(controller.reminder.region)
			DispatchQueue.main.async {
				self.removeAnnotation(controller.reminder)
				self.addAnnotation(controller.reminder)
			}
			
		case .remove:
			self.removeAnnotation(controller.reminder)
			RegionManager.shared.removeRegion(controller.reminder.region)
			
		default:
			break
			
		}
		self.dismiss(animated: true, completion: nil)
		
	}
	
	//MARK: - MKMapViewDelegate
	
	func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
		guard let location = userLocation.location else {
			return
		}
		if (goToUserLocation && location.horizontalAccuracy < 150 && userLocation.location!.horizontalAccuracy > 0) {
			var region = MKCoordinateRegion()
			region.center = location.coordinate
			
			let span: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
			region.span = span
			
			self.mapView.setRegion(region, animated: true)
			goToUserLocation = false
		}
	}
	
	func mapView(_ mapView: MKMapView, didFailToLocateUserWithError error: Error) {
		goToUserLocation = false
		print("didFailToLocateUserWithError: \(error.localizedDescription)")
	}
	
	// mapView:viewForAnnotation: provides the view for each annotation.
	// This method may be called for all or some of the added annotations.
	// For MapKit provided annotations (eg. MKUserLocation) return nil to use the MapKit provided annotation view.
	func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
		
		var annotationView: MKPinAnnotationView? = nil
		if let annotation = annotation as? ReminderAnnotation {
			annotationView = self.mapView.dequeueReusableAnnotationView(withIdentifier: kReminderAnnotationId) as? MKPinAnnotationView
			
			if annotationView == nil {
				annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: kReminderAnnotationId)
				annotationView?.canShowCallout = true
				annotationView?.animatesDrop = true
				annotationView?.isDraggable = true
				annotationView?.rightCalloutAccessoryView = UIButton(type: UIButton.ButtonType.detailDisclosure)
			}
		}
		
		return annotationView
	}
	
	// mapView:didAddAnnotationViews: is called after the annotation views have been added and positioned in the map.
	// The delegate can implement this method to animate the adding of the annotations views.
	// Use the current positions of the annotation views as the destinations of the animation.
	func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
		//ENTER_METHOD
	}
	
	// mapView:annotationView:calloutAccessoryControlTapped: is called when the user taps on left & right callout accessory UIControls.
	func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
		if let annotation = view.annotation as? ReminderAnnotation {
			let controller = ReminderAnnotationDetail.init(nibName: "ReminderAnnotationDetail", bundle: nil)
			controller.delegate = self
			controller.reminder = annotation
			controller.modalTransitionStyle = .crossDissolve//UIModalTransitionStyleFlipHorizontal
			self.present(controller, animated: true, completion: nil)
		}
	}
	
	func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
		var result: MKOverlayRenderer? = nil
		
		if let overlay = overlay as? ReminderAnnotation {
			result = ReminderCircleRenderer(reminder: overlay)
			(result as! MKOverlayPathRenderer).fillColor = UIColor.blue.withAlphaComponent(0.2)
			(result as! MKOverlayPathRenderer).strokeColor = UIColor.blue.withAlphaComponent(0.7)
			(result as! MKOverlayPathRenderer).lineWidth = 2.0
		}
		else if let overlay = overlay as? MKCircle {
			result = MKCircleRenderer(circle: overlay)
			(result as! MKOverlayPathRenderer).fillColor = UIColor.purple.withAlphaComponent(0.3)
		}
		
		return result!
	}
	
	func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
		//ENTER_METHOD
	}
	
	func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
		//ENTER_METHOD
	}
	
	func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationView.DragState, fromOldState oldState: MKAnnotationView.DragState) {
		switch newState {
		case .none:
			self.isDraggingPin = false
			if let reminder = view.annotation as? ReminderAnnotation {
				RegionManager.shared.addRegion(reminder.region)
			}
		case .starting:
			self.isDraggingPin = true
			fallthrough
		case .dragging, .canceling, .ending:
			if !self.isDraggingPin {
				// if we're here, we didn't get a start event, something is screwy
				print("Warning: we changed dragState to \(newState) passing through starting first")
			}
			
		}
		
	}
	
	
}

