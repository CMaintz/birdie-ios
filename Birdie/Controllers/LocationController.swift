import CoreLocation
import Foundation

@Observable
final class LocationController: NSObject {
    @ObservationIgnored private var locationManager: CLLocationManager?
    private let fixedLocation: Location?

    private(set) var currentLocation: Location?
    private(set) var locationError: String?

    /// Pass `fixedLocation` to bypass Core Location entirely (demo mode, previews, tests).
    init(fixedLocation: Location? = nil) {
        self.fixedLocation = fixedLocation
        super.init()
        if let fixedLocation {
            currentLocation = fixedLocation
        } else {
            checkLocationServices()
        }
    }

    func startUpdatingLocation() {
        guard fixedLocation == nil else { return }
        locationManager?.startUpdatingLocation()
    }

    func stopUpdatingLocation() {
        guard fixedLocation == nil else { return }
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
        locationManager = manager

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
            locationError = nil
        @unknown default:
            locationError = "Unknown authorization status"
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationController: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkAuthorizationStatus(manager)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latest = locations.last else { return }
        currentLocation = Location(from: latest.coordinate)
        locationError = nil
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Log.location.error("Location update failed: \(error.localizedDescription, privacy: .public)")
        locationError = error.localizedDescription
    }
}
