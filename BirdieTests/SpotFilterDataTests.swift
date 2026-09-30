import Testing
@testable import Birdie

struct SpotFilterDataTests {
    private let spots = [
        Fixtures.spot(id: "old-robin", .robin, daysAgo: 10, by: "alice"),
        Fixtures.spot(id: "new-owl", .owl, daysAgo: 1, by: "bob"),
        Fixtures.spot(id: "mid-robin-aarhus", .robin, daysAgo: 5, at: Fixtures.aarhus, by: "bob"),
        Fixtures.spot(id: "newest-swan", .swan, daysAgo: 0, by: "alice"),
    ]

    private func ids(_ spots: [BirdSpot]) -> [String?] { spots.map(\.id) }

    @Test func defaultFiltersKeepEverythingNewestFirst() {
        let result = SpotFilterData().apply(to: spots, currentUserID: "alice", userLocation: nil)
        #expect(ids(result) == ["newest-swan", "new-owl", "mid-robin-aarhus", "old-robin"])
    }

    @Test func filtersBySelectedSpecies() {
        var filters = SpotFilterData()
        filters.selectedSpecies = [BirdSpecies.robin.rawValue, BirdSpecies.swan.rawValue]

        let result = filters.apply(to: spots, currentUserID: nil, userLocation: nil)
        #expect(ids(result) == ["newest-swan", "mid-robin-aarhus", "old-robin"])
    }

    @Test func showOnlyMineKeepsTheCurrentUsersSpots() {
        var filters = SpotFilterData()
        filters.showOnlyMine = true

        let result = filters.apply(to: spots, currentUserID: "alice", userLocation: nil)
        #expect(ids(result) == ["newest-swan", "old-robin"])
    }

    @Test func showOnlyMineWithoutAUserMatchesNothing() {
        var filters = SpotFilterData()
        filters.showOnlyMine = true

        #expect(filters.apply(to: spots, currentUserID: nil, userLocation: nil).isEmpty)
    }

    @Test func distanceFilterDropsFarAwaySpots() {
        var filters = SpotFilterData()
        filters.isDistanceFilteringEnabled = true
        filters.maxDistance = 50

        let result = filters.apply(to: spots, currentUserID: nil, userLocation: Fixtures.copenhagen)
        #expect(!ids(result).contains("mid-robin-aarhus"))
        #expect(result.count == 3)
    }

    @Test func distanceFilterIsInclusiveOfTheRadius() {
        var filters = SpotFilterData()
        filters.isDistanceFilteringEnabled = true
        filters.maxDistance = 200

        let result = filters.apply(to: spots, currentUserID: nil, userLocation: Fixtures.copenhagen)
        #expect(result.count == spots.count)
    }

    @Test func distanceFilterIsSkippedWithoutALocation() {
        var filters = SpotFilterData()
        filters.isDistanceFilteringEnabled = true
        filters.maxDistance = 1

        #expect(filters.apply(to: spots, currentUserID: nil, userLocation: nil).count == spots.count)
    }

    @Test func filtersCombine() {
        var filters = SpotFilterData()
        filters.selectedSpecies = [BirdSpecies.robin.rawValue]
        filters.showOnlyMine = true
        filters.isDistanceFilteringEnabled = true
        filters.maxDistance = 10

        let result = filters.apply(to: spots, currentUserID: "bob", userLocation: Fixtures.aarhus)
        #expect(ids(result) == ["mid-robin-aarhus"])
    }
}
