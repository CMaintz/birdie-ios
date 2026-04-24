import CoreLocation
import Foundation

@Observable
class LocationController: NSObject, LocationServiceProtocol {
    
    private var locationManager: CLLocationManager?
    
    var currentLocation: Location? = nil
    var locationError: String? = nil
    
    override init() {
        super.init()
        checkLocationServices()
    }

    func startUpdatingLocation() {
        locationManager?.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        locationManager?.stopUpdatingLocation()
    }
    private func checkLocationServices() {
        DispatchQueue.global(qos: .userInitiated).async {
            let servicesEnabled = CLLocationManager.locationServicesEnabled()
            
            DispatchQueue.main.async {
                guard servicesEnabled else {
                    self.locationError = "Location services are disabled"
                    return
                }
                self.setupLocationManager()
            }
        }
    }
    
    private func setupLocationManager() {
        let manager = CLLocationManager()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager = manager
        
        if manager.authorizationStatus == .notDetermined {
            manager.requestWhenInUseAuthorization()
        } else {
            checkAuthorizationStatus(manager)
        }
    }
    
    private func checkAuthorizationStatus(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .restricted:
            locationError = "Location access is restricted"
        case .denied:
            locationError = "Location access denied"
        case .authorizedWhenInUse, .authorizedAlways:
            // Don't automatically start - let the caller decide
            //manager.startUpdatingLocation()
        @unknown default:
            locationError = "Unknown authorization status"
        }
    }
}

// MARK: - LocManager delegate

extension LocationController: CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkAuthorizationStatus(manager)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latest = locations.last else { return }
        self.currentLocation = Location(from: latest.coordinate)
        self.locationError = nil
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.locationError = error.localizedDescription
    }
}
