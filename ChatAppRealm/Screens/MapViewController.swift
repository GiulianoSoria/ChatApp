//
//  MapViewController.swift
//  ChatAppRealm
//
//  Created by Giuliano Soria Pazos on 2021-06-17.
//

import MapKit
import UIKit

class MapViewController: UIViewController {
  private var mapView: MKMapView!
  
  var location: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: MapDefaults.latitude,
                                                                longitude: MapDefaults.longitude)
  var annotationItems: [CAAnnotationItem] = []
  
  private var region: MKCoordinateRegion = MKCoordinateRegion(
    center: CLLocationCoordinate2D(latitude: LocationHelper.shared.locationManager.location?.coordinate.latitude ?? MapDefaults.latitude,
                                   longitude: LocationHelper.shared.locationManager.location?.coordinate.longitude ?? MapDefaults.longitude),
    span: MKCoordinateSpan(latitudeDelta: MapDefaults.zoomedIn,
                           longitudeDelta: MapDefaults.zoomedIn))
  
  private enum MapDefaults {
    static let latitude = 37.34
    static let longitude = -122.009163
    static let zoomedOut = 2.0
    static let zoomedIn = 0.01
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    setupLocation()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    configureViewController()
    configureMapView()
  }
  
  private func configureViewController() {
    view.backgroundColor = .systemBackground
  }
  
  private func configureMapView() {
    let annotation = CAAnnotationItem(coordinates: CLLocationCoordinate2D(latitude: region.center.latitude,
                                                                          longitude: region.center.latitude))
    annotationItems.append(annotation)
    
    mapView = MKMapView(frame: .zero)
    view.addSubview(mapView)
    mapView.pinToEdges(of: self.view)
    
    mapView.region = region
    mapView.mapType = .standard
    mapView.delegate = self
    
    mapView.showsUserLocation = true
    mapView.snapshotView(afterScreenUpdates: true)
    
    for annotationItem in annotationItems {
      let location = MKPointAnnotation()
      location.coordinate = CLLocationCoordinate2D(latitude: annotationItem.coordinates.latitude,
                                                   longitude: annotationItem.coordinates.longitude)
      mapView.addAnnotation(location)
    }
  }
  
  private func setupLocation() {
    region = MKCoordinateRegion(
      center: LocationHelper.shared.locationManager.location?.coordinate ?? location,
      span: MKCoordinateSpan(latitudeDelta: MapDefaults.zoomedIn,
                             longitudeDelta: MapDefaults.zoomedIn))
  }
}

extension MapViewController: CAMapViewDelegate {
  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    guard annotation is MKAnnotationView else { return nil }
    
    let identifier = "Location"
    var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
    
    if annotationView == nil {
      annotationView = MKPinAnnotationView(annotation: annotation,
                                           reuseIdentifier: identifier)
      annotationView?.canShowCallout = true
    } else {
      annotationView?.annotation = annotation
    }
    
    return annotationView
  }
}
