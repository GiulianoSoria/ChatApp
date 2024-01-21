//
//  LocationHelper.swift
//  ChatApp
//
//  Created by Giuliano Soria Pazos on 2021-06-03.
//

import CoreLocation
import UIKit

struct CAAnnotationItem: Identifiable {
  var coordinates: CLLocationCoordinate2D
  let id = UUID()
}

class LocationHelper: NSObject, ObservableObject {
  static let shared = LocationHelper()
  static let DefaultLocation = CLLocationCoordinate2D(latitude: 51.506520923981554,
                                                      longitude: -0.10689139236939127)
  
  static var currentLocation: CLLocationCoordinate2D {
    guard let location = shared.locationManager.location else {
      return DefaultLocation
    }
    
    return location.coordinate
  }
  
  public let locationManager = CLLocationManager()
  
  private override init() {
    super.init()
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    locationManager.requestWhenInUseAuthorization()
    locationManager.startUpdatingLocation()
  }
}

extension LocationHelper: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) { }
  
  public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print("Location manager failed with error: \(error.localizedDescription)")
  }
  
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    print("Location manager changed the status: \(status)")
    let preference: Preferences!
    switch status {
    case .authorized:
      preference = Preferences(isUserLocationShared: true)
    default:
      preference = Preferences(isUserLocationShared: false)
    }
    
		do {
			try PersistenceManager.shared.updatePreferences(
				preference: preference,
				types: [.isUserLocationShared]
			)
		} catch {
			UIHelpers.autoDismissableSnackBar(
				title: error.localizedDescription,
				image: .crossCircle,
				backgroundColor: .systemRed,
				textColor: .white,
				view: UIApplication.shared.windows.first(where: { $0.isKeyWindow })!.rootViewController!.view
			)
		}
  }
}
