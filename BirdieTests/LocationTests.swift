import Testing
@testable import Birdie

struct LocationTests {
    @Test func distanceBetweenCopenhagenAndAarhusIsAbout157Kilometres() {
        let kilometres = Fixtures.copenhagen.distance(to: Fixtures.aarhus) / 1000
        #expect(abs(kilometres - 157) < 3)
    }

    @Test func distanceToItselfIsZero() {
        #expect(Fixtures.copenhagen.distance(to: Fixtures.copenhagen) == 0)
    }

    @Test func isWithinRespectsTheRadius() {
        #expect(Fixtures.copenhagen.isWithin(200_000, of: Fixtures.aarhus))
        #expect(!Fixtures.copenhagen.isWithin(100_000, of: Fixtures.aarhus))
        #expect(Fixtures.copenhagen.isWithin(0, of: Fixtures.copenhagen))
    }

    @Test func formattedDistanceSwitchesToKilometresAboveOneKilometre() {
        let nearby = Location(latitude: 55.6761 + 0.0045, longitude: 12.5683)  // ~500 m north

        #expect(Fixtures.copenhagen.formattedDistance(to: nearby).hasSuffix(" m"))
        #expect(Fixtures.copenhagen.formattedDistance(to: Fixtures.aarhus).hasSuffix(" km"))
    }

    @Test func coordinateRoundTrips() {
        let location = Location(from: Fixtures.aarhus.coordinate)
        #expect(location == Fixtures.aarhus)
    }
}
