//
//  MapView.swift
//  ChatAppRealm
//
//  Created by Giuliano Soria Pazos on 2021-07-06.
//

import MapKit
import UIKit

protocol CAMapViewDelegate: MKMapViewDelegate { }

class CAMapView: UIView {
  weak var delegate: CAMapViewDelegate!
  
  var mapView: MKMapView!
  
  var location: CLLocationCoordinate2D!
  var region: MKCoordinateRegion!
  
  var annotationItem: CAAnnotationItem!
  
  init(location: CLLocationCoordinate2D, region: MKCoordinateRegion) {
    super.init(frame: .zero)
    self.location = location
    self.region = region
    configure()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  public func set(annotationItem: CAAnnotationItem) {
    self.annotationItem = annotationItem
    let location = MKPointAnnotation()
    location.coordinate = CLLocationCoordinate2D(latitude: annotationItem.coordinates.latitude,
                                                  longitude: annotationItem.coordinates.longitude)
    mapView.addAnnotation(location)
  }
  
  private func configure() {
    mapView = MKMapView(frame: .zero)
    addSubview(mapView)
    mapView.pinToEdges(of: self)
    
    mapView.region = region
    mapView.mapType = .standard
    mapView.delegate = delegate
    
    mapView.showsUserLocation = true
    mapView.snapshotView(afterScreenUpdates: true)
  }
}
