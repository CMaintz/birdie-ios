//
//  Location.swift
//  Birdie
//
//  Created by dmu mac 33 on 12/05/2025.
//

import CoreLocation
import Foundation

struct Location: Codable, Equatable {
    var latitude: Double
    var longitude: Double

    init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }

    init(from coordinate: CLLocationCoordinate2D) {
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
    }

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    var clLocation: CLLocation {
        CLLocation(latitude: latitude, longitude: longitude)
    }

    func distance(to other: Location) -> Double {
        clLocation.distance(from: other.clLocation)
    }

    func isWithin(_ meters: Double, of other: Location) -> Bool {
        distance(to: other) <= meters
    }
}

extension Location {
    func formattedDistance(to other: Location) -> String {
        let meters = distance(to: other)
        if meters > 1000 {
            return String(format: "%.1f km", meters / 1000)
        } else {
            return String(format: "%.0f m", meters)
        }
    }
}
