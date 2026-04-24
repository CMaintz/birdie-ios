//
//  SpotSeederService.swift
//  Birdie
//
//  Created by dmu mac 33 on 13/05/2025.
//

import Foundation

struct SpotSeederService {

    static func seedBirdSpots(for userID: String) async -> [BirdSpot] {
        let numberOfSpots = Int.random(in: 5...15)
        var spots: [BirdSpot] = []

        for _ in 0..<numberOfSpots {
            let birdSpot = generateRandomBirdSpot(for: userID)
            spots.append(birdSpot)
        }

        return spots
    }

    // MARK: - Helpers functions

    // Helper function to generate random bird spot data for a user
    private static func generateRandomBirdSpot(for userID: String) -> BirdSpot {
        let species = BirdSpecies.allCases.randomElement()!
        let location = generateRandomLocation()
        let note = generateRandomNote(for: species)
        let date = Calendar.current.date(
            byAdding: .day,
            value: -Int.random(in: 0...14),
            to: Date()
        )!

        return BirdSpot(
            species: species,
            date: date,
            location: location,
            note: note,
            userID: userID
        )
    }

    // Helper function to generate random location data (approx. long and lat of DK + some.
    private static func generateRandomLocation() -> Location {
        let randomLatitude = Double.random(in: 48.1...58.1)
        let randomLongitude = Double.random(in: 8.0...15.2)
        return Location(latitude: randomLatitude, longitude: randomLongitude)
    }

    // Helper function to generate a random, semi-coherent, slightly alien-sounding note
    private static func generateRandomNote(for species: BirdSpecies) -> String {
        // Word banks for various parts of the sentence
        //Inspired by caves of qud <3
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
        let locations = [
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
            "witnessed", "glanced", "glimpsed", "noted", "viewed",
        ]
        let idks = ["this", "a", "some"]
        // Randomly select words from the lists
        let adjective = adjectives.randomElement()!
        let action = actions.randomElement()!
        let accessory = accessories.randomElement()!
        let location = locations.randomElement()!
        let emotion = emotions.randomElement()!
        let synonym = spotSynonyms.randomElement()!
        let idk = idks.randomElement()!

        let note =
            "\(idk) \(species.rawValue) was \(synonym) \(action) \(location), \(adjective) and \(emotion), \(accessory)."

        return note
    }

    // MARK: - separate function to create additional spots, just to improve seeding of firestore
    
    static func createRegionalBirdSpots(for uids: [String]) async {
        let landRegions:
            [(latRange: ClosedRange<Double>, lonRange: ClosedRange<Double>)] = [
                (24.0...49.0, -125.0 ... -66.0),  // NA
                (-35.0 ... -10.0, 110.0...155.0),  // Australia
                (35.0...70.0, -10.0...40.0),  // Europe
                (-35.0...37.0, -70.0 ... -35.0),  // SA
                (5.0...55.0, 70.0...140.0),  // Asia
                (-35.0...35.0, -20.0...55.0),  // Africa
            ]
        var spots: [BirdSpot] = []
        var batchLimitReached = false

        while !batchLimitReached {
            for uid in uids {
                for _ in 1...Int.random(in: 5...15) {
                    if spots.count >= 499 {
                        batchLimitReached = true
                        break
                    }

                    let randomSpecies = BirdSpecies.allCases.randomElement()!
                    let randomDate = Calendar.current.date(
                        byAdding: .day,
                        value: -Int.random(in: 35...630),
                        to: Date()
                    )!

                    let region = landRegions.randomElement()!

                    let lat = Double.random(in: region.latRange)
                    let lon = Double.random(in: region.lonRange)
                    let location = Location(latitude: lat, longitude: lon)

                    let spot = BirdSpot(
                        species: randomSpecies,
                        date: randomDate,
                        location: location,
                        note: generateRandomNote(for: randomSpecies),
                        userID: uid
                    )
                    spots.append(spot)
                }
            }
        }
        do {
            try await FirestoreService.addSpotsBatch(spots)
        } catch {
            print("sample error!")
        }
        print("sample success!")
    }

    
    
    // MARK: - Ignore everything below this point, it's post-deadline!
    
    static func createSampleBirdSpots(uids: [String]) async {
        let baseLocation = Location(latitude: 37.3349, longitude: -122.0090)
        let baseCoordinate = baseLocation.coordinate
        var spots: [BirdSpot] = []
        
            for uid in uids {
                for _ in 1...Int.random(in: 5...15) {
               

                    let randomSpecies = BirdSpecies.allCases.randomElement()!
                    let randomDate = Calendar.current.date(
                        byAdding: .day,
                        value: -Int.random(in: 35...630),
                        to: Date()
                    )!

                    let latOffset = Double.random(in: -0.5757...3.6183)
                    let lonOffset = Double.random(in: -0.7085...9.4615)
                    let location = Location(
                        latitude: baseCoordinate.latitude + latOffset,
                        longitude: baseCoordinate.longitude + lonOffset
                    )

                    let spot = BirdSpot(
                        species: randomSpecies,
                        date: randomDate,
                        location: location,
                        note: generateRandomNote(for: randomSpecies),
                        userID: uid
                    )
                    spots.append(spot)
                }
            }
        do {
            try await FirestoreService.addSpotsBatch(spots)
        } catch {
            print("sample error!")
        }
        print("sample success!")
    }

    
    static func createGlobalBirdSpots(for uids: [String]) async {
        var spots: [BirdSpot] = []
        var batchLimitReached = false

        while !batchLimitReached {
            for uid in uids {
                for _ in 1...Int.random(in: 5...15) {
                    if spots.count >= 499 {
                        batchLimitReached = true
                        break
                    }

                    var validLocation: Location? = nil
                    var attempts = 0

                    while validLocation == nil && attempts < 15 {
                        let randomLocation = Location(
                            latitude: Double.random(in: -60.0...80.0),
                            longitude: Double.random(in: -180.0...180.0)
                        )

                        let isOnLand = await isLand(randomLocation)
                        if isOnLand {
                            validLocation = randomLocation
                        } else {
                            attempts += 1
                        }
                    }

                    let randomSpecies = BirdSpecies.allCases.randomElement()!
                    let randomDate = Calendar.current.date(
                        byAdding: .day,
                        value: -Int.random(in: 35...630),
                        to: Date()
                    )!
                    guard let location = validLocation else {
                        continue
                    }
                    let spot = BirdSpot(
                        species: randomSpecies,
                        date: randomDate,
                        location: location,
                        note: generateRandomNote(for: randomSpecies),
                        userID: uid
                    )

                    spots.append(spot)
                }
            }
        }

        do {
            try await FirestoreService.addSpotsBatch(spots)
        } catch {
            print("Error seeding global spots: \(error)")
        }

        print("Global bird spots created!")
    }

    static func isLand(_ location: Location) async -> Bool {
        let apiKey = SecretKeys.openCageKey
        let urlString =
            "https://api.opencagedata.com/geocode/v1/json?q=\(location.latitude),\(location.longitude)&key=\(apiKey)&no_annotations=1"

        guard let url = URL(string: urlString) else { return false }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard
                let json = try JSONSerialization.jsonObject(with: data)
                    as? [String: Any],
                let results = json["results"] as? [[String: Any]]
            else {
                return false
            }

            // If OpenCage returns results, it's land!..ish
            return !results.isEmpty
        } catch {
            print("Failed land check: \(error.localizedDescription)")
            return false
        }
    }



}
