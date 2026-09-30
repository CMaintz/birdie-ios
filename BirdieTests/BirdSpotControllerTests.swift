import Foundation
import Testing
@testable import Birdie

struct BirdSpotControllerTests {
    private let repository: MockSpotRepository
    private let controller: BirdSpotController

    init() {
        repository = MockSpotRepository()
        controller = BirdSpotController(repository: repository)
    }

    // MARK: - Loading

    @Test func loadSpotsSortsNewestFirst() async {
        repository.spotsToReturn = [
            Fixtures.spot(id: "a", daysAgo: 3),
            Fixtures.spot(id: "b", daysAgo: 0),
            Fixtures.spot(id: "c", daysAgo: 7),
        ]

        await controller.loadSpots(currentUserID: "alice", near: nil)

        #expect(controller.spots.map(\.id) == ["b", "a", "c"])
        #expect(controller.errorMessage == nil)
        #expect(!controller.isLoading)
    }

    @Test func loadSpotsPassesFiltersAndUserToTheRepository() async {
        controller.filters.showOnlyMine = true
        controller.filters.selectedSpecies = ["Owl"]

        await controller.loadSpots(currentUserID: "alice", near: nil)

        #expect(repository.fetchCalls.count == 1)
        #expect(repository.fetchCalls.first?.userID == "alice")
        #expect(repository.fetchCalls.first?.filters == controller.filters)
    }

    @Test func loadSpotsAppliesDistanceFilterClientSide() async {
        repository.spotsToReturn = [
            Fixtures.spot(id: "near", at: Fixtures.copenhagen),
            Fixtures.spot(id: "far", at: Fixtures.aarhus),
        ]
        controller.filters.isDistanceFilteringEnabled = true
        controller.filters.maxDistance = 25

        await controller.loadSpots(currentUserID: nil, near: Fixtures.copenhagen)

        #expect(controller.spots.map(\.id) == ["near"])
    }

    @Test func loadSpotsFailureSurfacesAnErrorAndKeepsExistingSpots() async {
        repository.spotsToReturn = [Fixtures.spot(id: "kept")]
        await controller.loadSpots(currentUserID: nil, near: nil)

        repository.errorToThrow = TestError()
        await controller.loadSpots(currentUserID: nil, near: nil)

        #expect(controller.spots.map(\.id) == ["kept"])
        #expect(controller.errorMessage?.contains("backend unavailable") == true)
    }

    // MARK: - Counting

    @Test func spotCountReturnsRepositoryValue() async {
        repository.countToReturn = 4
        #expect(await controller.spotCount(for: "alice") == 4)
    }

    @Test func spotCountReturnsNilOnFailure() async {
        repository.errorToThrow = TestError()
        #expect(await controller.spotCount(for: "alice") == nil)
    }

    // MARK: - Adding

    @Test func addStoresATrimmedSpot() async throws {
        let date = Fixtures.referenceDate
        try await controller.add(
            species: .heron,
            location: Fixtures.aarhus,
            note: "  by the lake \n",
            userID: "alice",
            date: date
        )

        let stored = try #require(repository.addedSpots.first)
        #expect(stored.species == .heron)
        #expect(stored.location == Fixtures.aarhus)
        #expect(stored.note == "by the lake")
        #expect(stored.userID == "alice")
        #expect(stored.date == date)
    }

    @Test func addTurnsABlankNoteIntoNil() async throws {
        try await controller.add(species: .owl, location: Fixtures.copenhagen, note: "   ", userID: "alice")
        #expect(repository.addedSpots.first?.note == nil)
    }

    @Test func addRequiresASpecies() async {
        await #expect(throws: FormError.missingSpecies) {
            try await controller.add(species: nil, location: Fixtures.copenhagen, note: "", userID: "alice")
        }
        #expect(repository.addedSpots.isEmpty)
    }

    @Test func addRequiresALocation() async {
        await #expect(throws: FormError.missingLocation) {
            try await controller.add(species: .owl, location: nil, note: "", userID: "alice")
        }
        #expect(repository.addedSpots.isEmpty)
    }

    @Test func addRequiresASignedInUser() async {
        await #expect(throws: FormError.notSignedIn) {
            try await controller.add(species: .owl, location: Fixtures.copenhagen, note: "", userID: nil)
        }
        #expect(repository.addedSpots.isEmpty)
    }

    @Test func addPropagatesRepositoryErrors() async {
        repository.errorToThrow = TestError()
        await #expect(throws: TestError.self) {
            try await controller.add(species: .owl, location: Fixtures.copenhagen, note: "", userID: "alice")
        }
    }

    // MARK: - Deleting

    @Test func deleteRemovesOwnSpot() async {
        repository.spotsToReturn = [Fixtures.spot(id: "mine", by: "alice"), Fixtures.spot(id: "other", by: "bob")]
        await controller.loadSpots(currentUserID: "alice", near: nil)

        let deleted = await controller.delete(controller.spots.first { $0.id == "mine" }!, as: "alice")

        #expect(deleted)
        #expect(repository.deletedIDs == ["mine"])
        #expect(controller.spots.map(\.id) == ["other"])
    }

    @Test func deleteRefusesSomeoneElsesSpot() async {
        let deleted = await controller.delete(Fixtures.spot(id: "bobs", by: "bob"), as: "alice")

        #expect(!deleted)
        #expect(repository.deletedIDs.isEmpty)
        #expect(controller.errorMessage == FormError.notOwner.localizedDescription)
    }

    @Test func deleteRefusesWhenSignedOut() async {
        let deleted = await controller.delete(Fixtures.spot(by: "alice"), as: nil)
        #expect(!deleted)
        #expect(repository.deletedIDs.isEmpty)
    }

    @Test func deleteFailureSurfacesAnError() async {
        repository.errorToThrow = TestError()

        let deleted = await controller.delete(Fixtures.spot(id: "mine", by: "alice"), as: "alice")

        #expect(!deleted)
        #expect(controller.errorMessage?.contains("backend unavailable") == true)
    }

    @Test func canDeleteRequiresOwnershipAndAStoredID() {
        #expect(controller.canDelete(Fixtures.spot(by: "alice"), as: "alice"))
        #expect(!controller.canDelete(Fixtures.spot(by: "bob"), as: "alice"))
        #expect(!controller.canDelete(Fixtures.spot(id: nil, by: "alice"), as: "alice"))
        #expect(!controller.canDelete(Fixtures.spot(by: "alice"), as: nil))
    }
}
