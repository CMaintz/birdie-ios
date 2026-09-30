//
//  SpotSeederService.swift
//  Birdie
//
//  Created by dmu mac 33 on 13/05/2025.
//

#if DEBUG
import Foundation

/// Debug-only generator for random sightings. Nothing here runs unless called explicitly.
struct SpotSeederService {
    /// Firestore batches are limited to 500 writes.
    private static let batchLimit = 499

    let repository: SpotRepositoryProtocol

    /// 5-15 random sightings in and around Denmark from the last two weeks.
    func randomSpots(for userID: String) -> [BirdSpot] {
        (0..<Int.random(in: 5...15)).map { _ in
            let species = BirdSpecies.allCases.randomElement()!
            return BirdSpot(
                species: species,
                date: Self.randomDate(daysAgo: 0...14),
                location: Location(
                    latitude: Double.random(in: 48.1...58.1),
                    longitude: Double.random(in: 8.0...15.2)
                ),
                note: Self.randomNote(for: species),
                userID: userID
            )
        }
    }

    /// Spreads older sightings for the given users across rough land boxes on each continent.
    func createRegionalBirdSpots(for userIDs: [String]) async throws {
        let landRegions: [(lat: ClosedRange<Double>, lon: ClosedRange<Double>)] = [
            (24.0...49.0, -125.0 ... -66.0),  // North America
            (-35.0 ... -10.0, 110.0...155.0),  // Australia
            (35.0...70.0, -10.0...40.0),  // Europe
            (-35.0...37.0, -70.0 ... -35.0),  // South America
            (5.0...55.0, 70.0...140.0),  // Asia
            (-35.0...35.0, -20.0...55.0),  // Africa
        ]
        guard !userIDs.isEmpty else { return }

        var spots: [BirdSpot] = []
        while spots.count < Self.batchLimit {
            for userID in userIDs where spots.count < Self.batchLimit {
                let region = landRegions.randomElement()!
                let species = BirdSpecies.allCases.randomElement()!
                spots.append(
                    BirdSpot(
                        species: species,
                        date: Self.randomDate(daysAgo: 35...630),
                        location: Location(
                            latitude: Double.random(in: region.lat),
                            longitude: Double.random(in: region.lon)
                        ),
                        note: Self.randomNote(for: species),
                        userID: userID
                    )
                )
            }
        }
        try await repository.addSpots(spots)
    }

    /// Like `createRegionalBirdSpots`, but samples the whole globe and asks the
    /// OpenCage geocoder whether each point is on land. Needs `Secrets.plist`.
    func createGlobalBirdSpots(for userIDs: [String]) async throws {
        guard !userIDs.isEmpty else { return }

        var spots: [BirdSpot] = []
        var attempts = 0
        while spots.count < Self.batchLimit, attempts < Self.batchLimit * 15 {
            attempts += 1
            let candidate = Location(
                latitude: Double.random(in: -60.0...80.0),
                longitude: Double.random(in: -180.0...180.0)
            )
            guard await Self.isLand(candidate) else { continue }

            let species = BirdSpecies.allCases.randomElement()!
            spots.append(
                BirdSpot(
                    species: species,
                    date: Self.randomDate(daysAgo: 35...630),
                    location: candidate,
                    note: Self.randomNote(for: species),
                    userID: userIDs[spots.count % userIDs.count]
                )
            )
        }
        try await repository.addSpots(spots)
    }

    // MARK: - Helpers

    private static func randomDate(daysAgo range: ClosedRange<Int>) -> Date {
        Calendar.current.date(byAdding: .day, value: -Int.random(in: range), to: Date())!
    }

    private static func isLand(_ location: Location) async -> Bool {
        var components = URLComponents(string: "https://api.opencagedata.com/geocode/v1/json")!
        components.queryItems = [
            URLQueryItem(name: "q", value: "\(location.latitude),\(location.longitude)"),
            URLQueryItem(name: "key", value: SecretKeys.openCageKey),
            URLQueryItem(name: "no_annotations", value: "1"),
        ]
        guard let url = components.url else { return false }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                let results = json["results"] as? [[String: Any]]
            else {
                return false
            }
            // OpenCage only returns results for points it can place, which is mostly land.
            return !results.isEmpty
        } catch {
            Log.seeding.error("Land check failed: \(error.localizedDescription, privacy: .public)")
            return false
        }
    }

    /// A random, semi-coherent, slightly alien-sounding note. Inspired by Caves of Qud.
    static func randomNote(for species: BirdSpecies) -> String {
        let adjectives = [
            "mysterious", "sparkling", "confused", "wobbly", "fancy", "curious",
            "fluffy", "squeaky", "sneaky", "sleepy", "attractive", "bald",
            "beautiful", "dazzling", "drab", "elegant", "glamorous", "gorgeous",
            "handsome", "magnificent", "hideous", "muscular", "unkempt",
            "unsightly", "delightful", "ambitious", "agreeable", "grumpy",
            "clumsy", "bewildered", "embarrassed", "nervous", "obnoxious",
            "rude", "gigantic", "immense",
        ]
        let actions = [
            "dancing", "squawking", "hopping", "napping", "flapping",
            "rolling around", "eating a sandwich", "trying to juggle",
            "hiding behind a bush", "staring into the distance",
            "waving goodbye", "blinking slowly", "flapping its wings rapidly",
            "chirping cheerfully", "singing a song", "dancing in the rain",
        ]
        let accessories = [
            "wearing a tiny hat", "carrying an umbrella", "wearing sunglasses",
            "eating spaghetti", "wearing a bowtie", "carrying a briefcase",
            "rocking a monocle", "having a cup of coffee", "wearing a scarf",
            "riding a bicycle",
        ]
        let places = [
            "on top of a fence", "in the middle of a street", "under a tree",
            "on a park bench", "next to a vending machine",
            "in a busy shopping mall", "by the lake",
            "on the roof of a building", "in front of a bus stop",
            "on the moon",
        ]
        let emotions = [
            "very confused", "mildly annoyed", "extremely excited",
            "bitterly disappointed", "wonderfully surprised",
            "calmly indifferent", "overly dramatic", "suspiciously quiet",
        ]
        let spotSynonyms = [
            "spotted", "seen", "observed", "admired", "encountered", "watched",
            "perceived", "noticed", "sighted", "detected", "beheld",
            "witnessed", "glimpsed", "noted", "viewed",
        ]
        let articles = ["this", "a", "some"]

        return "\(articles.randomElement()!) \(species.rawValue) was \(spotSynonyms.randomElement()!) \(actions.randomElement()!) \(places.randomElement()!), \(adjectives.randomElement()!) and \(emotions.randomElement()!), \(accessories.randomElement()!)."
    }
}
#endif
