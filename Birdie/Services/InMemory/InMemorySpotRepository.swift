import Foundation

/// Spot storage kept entirely in memory. Mirrors the server-side filtering Firestore does.
final class InMemorySpotRepository: SpotRepositoryProtocol {
    private(set) var spots: [BirdSpot]

    init(spots: [BirdSpot] = []) {
        self.spots = spots.map { spot in
            var spot = spot
            if spot.id == nil { spot.id = UUID().uuidString }
            return spot
        }
    }

    func fetchSpots(with filters: SpotFilterData, currentUserID: String?) async throws -> [BirdSpot] {
        spots
            .filter { filters.selectedSpecies.isEmpty || filters.selectedSpecies.contains($0.species.rawValue) }
            .filter { !filters.showOnlyMine || currentUserID == nil || $0.userID == currentUserID }
            .sorted { $0.date > $1.date }
    }

    func addSpot(_ spot: BirdSpot) async throws {
        var spot = spot
        spot.id = UUID().uuidString
        spots.append(spot)
    }

    func deleteSpot(id: String) async throws {
        guard spots.contains(where: { $0.id == id }) else { throw SpotRepositoryError.spotNotFound }
        spots.removeAll { $0.id == id }
    }

    func spotCount(for userID: String) async throws -> Int {
        spots.filter { $0.userID == userID }.count
    }

    func addSpots(_ newSpots: [BirdSpot]) async throws {
        for spot in newSpots {
            try await addSpot(spot)
        }
    }
}
