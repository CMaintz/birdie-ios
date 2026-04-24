//
//  BirdSpotController.swift
//  Birdie
//
//  Created by dmu mac 33 on 12/05/2025.
//

import Foundation

@Observable
class BirdSpotController {
    private(set) var spots: [BirdSpot] = []
    var filters: SpotFilterData = SpotFilterData()

    init() {
        Task {
            do {
                try await spots = FirestoreService.fetchSpots(with: filters)
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    func spotCount(for userID: String) async -> Int {
        do {
            return try await FirestoreService.fetchSpottingCount(for: userID)
        } catch {
            print(error.localizedDescription)
        }
        return 0
    }

    func updateSpots(currentLocation: Location?) async {
        do {
            var fetched = try await FirestoreService.fetchSpots(with: filters)
            if filters.isDistanceFilteringEnabled, let userLoc = currentLocation
            {
                fetched = fetched.filter {
                    $0.location.isWithin(
                        filters.maxDistance * 1000,
                        of: userLoc
                    )
                }
            }
            self.spots = fetched
        } catch {
            print("Failed to fetch filtered spots: \(error)")
        }
    }

    func add(
        _ species: BirdSpecies,
        _ location: Location,
        _ note: String?,
        _ userID: String
    ) async {
        do {
            let spot = BirdSpot(
                species: species,
                date: Date(),
                location: location,
                note: note,
                userID: userID
            )
            try await FirestoreService.addSpot(spot)
        } catch {
            print(error.localizedDescription)
        }

    }

    func delete(_ spot: BirdSpot, _ userID: String) async {
        if spot.userID != userID { return }
        do {
            guard let spotID = spot.id else { return }
            try await FirestoreService.deleteSpot(spotID)
        } catch {
            print(error.localizedDescription)
        }
    }

}
