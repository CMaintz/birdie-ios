//
//  SpotFilterData.swift
//  Birdie
//
//  Created by dmu mac 33 on 15/05/2025.
//

import Foundation

struct SpotFilterData: Equatable {
    /// Firestore `in` queries are capped, and the picker enforces this limit.
    static let maxSelectableSpecies = 10

    var selectedSpecies: Set<String> = []
    /// Kilometres.
    var maxDistance: Double = 50
    var showOnlyMine: Bool = false
    var isDistanceFilteringEnabled: Bool = false

    /// Applies every filter client-side and orders the result newest first.
    /// Distance filtering is skipped when the user's location is unknown.
    func apply(
        to spots: [BirdSpot],
        currentUserID: String?,
        userLocation: Location?
    ) -> [BirdSpot] {
        spots
            .filter { spot in
                if !selectedSpecies.isEmpty,
                    !selectedSpecies.contains(spot.species.rawValue)
                {
                    return false
                }
                if showOnlyMine, spot.userID != currentUserID {
                    return false
                }
                if isDistanceFilteringEnabled, let userLocation,
                    !spot.location.isWithin(maxDistance * 1000, of: userLocation)
                {
                    return false
                }
                return true
            }
            .sorted { $0.date > $1.date }
    }
}
