
import Foundation
import MapKit

public protocol LocationManagerDelegate: AnyObject {
    func didUpdateLocation(_ location: CLLocation?)
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus)
}

public class LocationManager: NSObject {
    public weak var delegate: LocationManagerDelegate?
    private var locManager = CLLocationManager()
    
    public static let shared = LocationManager()
    public var currentLocation: CLLocation?

    override init() {
        super.init()
        locManager.allowsBackgroundLocationUpdates = true
        locManager.distanceFilter = 10;
        locManager.pausesLocationUpdatesAutomatically = false
        locManager.delegate = self
    }
  
    public func requestLocation() {
        if locManager.authorizationStatus == .notDetermined {
            locManager.requestAlwaysAuthorization()
            locManager.startUpdatingLocation()

        } else if (locManager.authorizationStatus == .denied) {
            print("Authorization denied")
        } else {
          locManager.startUpdatingLocation()
        }
    }
    
    public func stopUpdatingLocation() {
        locManager.stopUpdatingLocation()
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationManager: CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways || status == .authorizedWhenInUse {
          manager.startUpdatingLocation()
        } else if status == .restricted {
            currentLocation = Constants.defaultLocation
        } else {
            currentLocation = nil
        }
        delegate?.locationManager(manager, didChangeAuthorization: status)
    }

    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.first
        self.delegate?.didUpdateLocation(locations.first)
        print("Did update new location \(currentLocation!.coordinate)")
    }

    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("LocationManager fail with error \(error.localizedDescription)")
    }
}
