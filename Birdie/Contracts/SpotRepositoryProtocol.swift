import Foundation

protocol SpotRepositoryProtocol: AnyObject {
    /// Returns spots matching the species / "only mine" parts of `filters`.
    /// Distance filtering and final ordering are applied by `BirdSpotController`.
    func fetchSpots(with filters: SpotFilterData, currentUserID: String?) async throws -> [BirdSpot]

    func addSpot(_ spot: BirdSpot) async throws

    func deleteSpot(id: String) async throws

    func spotCount(for userID: String) async throws -> Int

    func addSpots(_ spots: [BirdSpot]) async throws
}

enum SpotRepositoryError: LocalizedError, Equatable {
    case spotNotFound

    var errorDescription: String? {
        switch self {
        case .spotNotFound: "That sighting no longer exists."
        }
    }
}
