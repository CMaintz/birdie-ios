import Foundation
@testable import Birdie

enum Fixtures {
    static let copenhagen = Location(latitude: 55.6761, longitude: 12.5683)
    static let aarhus = Location(latitude: 56.1629, longitude: 10.2039)
    static let referenceDate = Date(timeIntervalSince1970: 1_750_000_000)

    static func spot(
        id: String? = UUID().uuidString,
        _ species: BirdSpecies = .robin,
        daysAgo: Double = 0,
        at location: Location = copenhagen,
        by userID: String = "alice"
    ) -> BirdSpot {
        BirdSpot(
            id: id,
            species: species,
            date: referenceDate.addingTimeInterval(-daysAgo * 86_400),
            location: location,
            note: nil,
            userID: userID
        )
    }
}

struct TestError: LocalizedError, Equatable {
    var errorDescription: String? { "backend unavailable" }
}

/// Records calls and returns canned results, so controller logic can be tested in isolation.
final class MockSpotRepository: SpotRepositoryProtocol {
    var spotsToReturn: [BirdSpot] = []
    var countToReturn = 0
    var errorToThrow: Error?

    private(set) var fetchCalls: [(filters: SpotFilterData, userID: String?)] = []
    private(set) var addedSpots: [BirdSpot] = []
    private(set) var deletedIDs: [String] = []

    func fetchSpots(with filters: SpotFilterData, currentUserID: String?) async throws -> [BirdSpot] {
        fetchCalls.append((filters, currentUserID))
        if let errorToThrow { throw errorToThrow }
        return spotsToReturn
    }

    func addSpot(_ spot: BirdSpot) async throws {
        if let errorToThrow { throw errorToThrow }
        addedSpots.append(spot)
    }

    func deleteSpot(id: String) async throws {
        if let errorToThrow { throw errorToThrow }
        deletedIDs.append(id)
    }

    func spotCount(for userID: String) async throws -> Int {
        if let errorToThrow { throw errorToThrow }
        return countToReturn
    }

    func addSpots(_ spots: [BirdSpot]) async throws {
        if let errorToThrow { throw errorToThrow }
        addedSpots += spots
    }
}
