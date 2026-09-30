import Foundation
import Testing
@testable import Birdie

struct AppModeTests {
    @Test func defaultsToFirebase() {
        #expect(AppMode.resolve(arguments: ["Birdie"], environment: [:]) == .firebase)
    }

    @Test func demoLaunchArgumentSelectsDemoMode() {
        #expect(AppMode.resolve(arguments: ["Birdie", "--demo"], environment: [:]) == .demo)
    }

    @Test func runningUnderXCTestSelectsDemoMode() {
        let environment = ["XCTestConfigurationFilePath": "/tmp/config.xctestconfiguration"]
        #expect(AppMode.resolve(arguments: ["Birdie"], environment: environment) == .demo)
    }

    @Test func initialTabIsReadFromLaunchArguments() {
        #expect(LaunchOptions.initialTab(arguments: ["Birdie", "--demo", "--tab", "map"]) == "map")
        #expect(LaunchOptions.initialTab(arguments: ["Birdie", "--tab"]) == nil)
        #expect(LaunchOptions.initialTab(arguments: ["Birdie"]) == nil)
    }
}

struct DemoDataTests {
    @Test func demoSpotsAreCloseEnoughToShowOnTheMap() {
        let spots = DemoData.spots(relativeTo: Fixtures.referenceDate)
        #expect(!spots.isEmpty)
        #expect(spots.allSatisfy { $0.location.isWithin(1_000, of: DemoData.location) })
    }

    @Test func demoSpotsHaveUniqueIDsAndPastDates() {
        let spots = DemoData.spots(relativeTo: Fixtures.referenceDate)
        #expect(Set(spots.compactMap(\.id)).count == spots.count)
        #expect(spots.allSatisfy { $0.date <= Fixtures.referenceDate })
    }

    @Test func demoServicesStartSignedInAsTheDemoUser() async throws {
        let services = AppServices.demo(now: Fixtures.referenceDate)
        #expect(services.mode == .demo)
        #expect(services.auth.currentUser == DemoData.user)
        #expect(services.fixedLocation == DemoData.location)

        let count = try await services.spots.spotCount(for: DemoData.user.id)
        #expect(count > 0)
    }
}

struct InMemorySpotRepositoryTests {
    @Test func fetchMirrorsServerSideFilters() async throws {
        let repository = InMemorySpotRepository(spots: [
            Fixtures.spot(id: "1", .owl, daysAgo: 2, by: "alice"),
            Fixtures.spot(id: "2", .robin, daysAgo: 1, by: "bob"),
            Fixtures.spot(id: "3", .owl, daysAgo: 0, by: "bob"),
        ])
        var filters = SpotFilterData()
        filters.selectedSpecies = ["Owl"]
        filters.showOnlyMine = true

        let result = try await repository.fetchSpots(with: filters, currentUserID: "bob")
        #expect(result.map(\.id) == ["3"])
    }

    @Test func addAssignsAnIDAndDeleteRemovesIt() async throws {
        let repository = InMemorySpotRepository()
        try await repository.addSpot(Fixtures.spot(id: nil, by: "alice"))

        let stored = try #require(repository.spots.first)
        let id = try #require(stored.id)
        #expect(try await repository.spotCount(for: "alice") == 1)

        try await repository.deleteSpot(id: id)
        #expect(repository.spots.isEmpty)
    }

    @Test func deletingAnUnknownSpotThrows() async {
        let repository = InMemorySpotRepository()
        await #expect(throws: SpotRepositoryError.spotNotFound) {
            try await repository.deleteSpot(id: "missing")
        }
    }
}
