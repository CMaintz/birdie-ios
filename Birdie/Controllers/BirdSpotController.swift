//
//  BirdSpotController.swift
//  Birdie
//
//  Created by dmu mac 33 on 12/05/2025.
//

import Foundation

@Observable
final class BirdSpotController {
    private(set) var spots: [BirdSpot] = []
    private(set) var isLoading = false
    /// Last user-facing error from loading or deleting; shown in an alert.
    var errorMessage: String?
    var filters = SpotFilterData()

    private let repository: SpotRepositoryProtocol

    init(repository: SpotRepositoryProtocol) {
        self.repository = repository
    }

    func loadSpots(currentUserID: String?, near location: Location?) async {
        isLoading = true
        defer { isLoading = false }
        do {
            let fetched = try await repository.fetchSpots(with: filters, currentUserID: currentUserID)
            spots = filters.apply(to: fetched, currentUserID: currentUserID, userLocation: location)
        } catch {
            report(error, while: "loading sightings")
        }
    }

    /// Returns `nil` when the count couldn't be fetched.
    func spotCount(for userID: String) async -> Int? {
        do {
            return try await repository.spotCount(for: userID)
        } catch {
            Log.spots.error("Counting spots failed: \(error.localizedDescription, privacy: .public)")
            return nil
        }
    }

    /// Validates the input and stores a new sighting. Throws `FormError` or the repository's error.
    func add(
        species: BirdSpecies?,
        location: Location?,
        note: String,
        userID: String?,
        date: Date = Date()
    ) async throws {
        guard let userID else { throw FormError.notSignedIn }
        guard let species else { throw FormError.missingSpecies }
        guard let location else { throw FormError.missingLocation }

        let trimmedNote = note.trimmed
        let spot = BirdSpot(
            species: species,
            date: date,
            location: location,
            note: trimmedNote.isEmpty ? nil : trimmedNote,
            userID: userID
        )
        do {
            try await repository.addSpot(spot)
        } catch {
            Log.spots.error("Adding spot failed: \(error.localizedDescription, privacy: .public)")
            throw error
        }
    }

    func canDelete(_ spot: BirdSpot, as userID: String?) -> Bool {
        userID != nil && spot.userID == userID && spot.id != nil
    }

    /// Deletes a spot owned by `userID`. On failure sets `errorMessage` and returns `false`.
    @discardableResult
    func delete(_ spot: BirdSpot, as userID: String?) async -> Bool {
        guard let spotID = spot.id, canDelete(spot, as: userID) else {
            errorMessage = FormError.notOwner.localizedDescription
            return false
        }
        do {
            try await repository.deleteSpot(id: spotID)
            spots.removeAll { $0.id == spotID }
            return true
        } catch {
            report(error, while: "deleting the sighting")
            return false
        }
    }

    private func report(_ error: Error, while action: String) {
        Log.spots.error("Failed \(action, privacy: .public): \(error.localizedDescription, privacy: .public)")
        errorMessage = "Failed \(action): \(error.localizedDescription)"
    }
}
