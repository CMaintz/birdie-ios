protocol LocationServiceProtocol {
    var currentLocation: Location? { get }
    var locationError: String? { get }
    func startUpdatingLocation()
    func stopUpdatingLocation()
}