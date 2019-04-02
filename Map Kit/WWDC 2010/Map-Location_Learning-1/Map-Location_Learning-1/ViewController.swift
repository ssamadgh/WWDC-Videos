//
//  ViewController.swift
//  Map-Location_Learning-1
//
//  Created by Seyed Samad Gholamzadeh on 10/23/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
	
	var locationManager: CLLocationManager!
	var mapView: MKMapView!
	var annotation: MKPointAnnotation!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.locationManager = CLLocationManager()
		
		self.enableBasicLocationServices()
		if CLLocationManager.locationServicesEnabled() {
			print("locationServicesEnabled")
			self.locationManager.startUpdatingLocation()
		}
		
		self.configureMapView()
//		self.configure3DMapView()
		self.configureAnnotation()
		self.view.addSubview(self.mapView)

		
	}
	
	func configureMapView() {
		self.mapView = MKMapView(frame: self.view.frame)
		self.mapView.region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 35.6, longitude: 51.4), span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
		self.mapView.userTrackingMode = .follow
		self.mapView.showsUserLocation = true
		self.mapView.delegate = self
		self.mapView.isUserInteractionEnabled = true
		self.mapView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(longPress(_:))))
	}
	
	@objc func longPress(_ sender: UILongPressGestureRecognizer) {
		let point = sender.location(in: sender.view)
		let coordinate = self.mapView.convert(point, toCoordinateFrom: sender.view)
		
//		UIView.animate(withDuration: 0.2) {
//			self.annotation.coordinate = coordinate
//		}
		
		var region = self.mapView.region
		region.center = coordinate
		region.span.latitudeDelta *= region.span.latitudeDelta*0.1
		region.span.longitudeDelta *= region.span.longitudeDelta*0.1

		self.mapView.setRegion(region, animated: true)
	}
	
	func configure3DMapView() {
		// Create a coordinate structure for the location.
		let ground = CLLocationCoordinate2D(latitude: 35.68, longitude: 51.48)
		
		// Create a coordinate structure for the point on the ground from which to view the location.
		let eye = CLLocationCoordinate2D(latitude: 35.6, longitude: 51.4)
		
		// Ask Map Kit for a camera that looks at the location from an altitude of 100 meters above the eye coordinates.
		let myCamera = MKMapCamera(lookingAtCenter: ground, fromEyeCoordinate: eye, eyeAltitude: 300)
//		let myCamera = MKMapCamera(lookingAtCenter: ground, fromDistance: 100, pitch: 45, heading: 0)

		
		// Assign the camera to your map view.
		mapView.camera = myCamera

	}
	
	func configureAnnotation() {
		self.annotation = MKPointAnnotation()
		annotation.coordinate = CLLocationCoordinate2D(latitude: 35.68, longitude: 51.48)
		
		annotation.title = "Hello Tehran"
		annotation.subtitle = "Here is tehran"
		self.mapView.addAnnotation(annotation)
	}
	
	func enableBasicLocationServices() {
		locationManager.delegate = self

		switch CLLocationManager.authorizationStatus() {
		case .notDetermined:
			// Request when-in-use authorization initially
			locationManager.requestWhenInUseAuthorization()
			print("Wow, its not determined")
			break
			
		case .restricted, .denied:
			// Disable location features
			disableMyLocationBasedFeatures()
			print("Oh it's denied")
			break
			
		case .authorizedWhenInUse, .authorizedAlways:
			// Enable location features
			enableMyWhenInUseFeatures()
			break
		}
	}
	
	func disableMyLocationBasedFeatures() {
		print("my LocationBasedFeatures is disable")
	}
	
	func enableMyWhenInUseFeatures() {
		print("my LocationBasedFeatures is enable")
	}
	
	func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
		switch status {
		case .restricted, .denied:
			disableMyLocationBasedFeatures()
			break
			
		case .authorizedWhenInUse:
			enableMyWhenInUseFeatures()
			break
			
		case .notDetermined, .authorizedAlways:
			break
		}
	}
	
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		print("didUpdateLocations ", locations.first)

	}
	
	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		print("didFailWithError ", error)

	}
	
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		self.mapView.frame = self.view.frame

	}
	
	
	func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
		let view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "Hello")
		view.pinTintColor = .yellow
		view.isDraggable = true
		return view
	}
	
	func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationView.DragState, fromOldState oldState: MKAnnotationView.DragState) {
		print(view.annotation!.coordinate)
	}
}

