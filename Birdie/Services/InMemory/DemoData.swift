import Foundation

/// Fixed sample data for demo mode (`--demo`), previews and tests.
enum DemoData {
    static let password = "demo-password"

    static let user = BirdieUser(
        id: "demo-user",
        email: "demo@birdie.example",
        displayName: "Demo Birder",
        imageURL: nil
    )

    /// Copenhagen city centre.
    static let location = Location(latitude: 55.6761, longitude: 12.5683)

    static func spots(relativeTo now: Date) -> [BirdSpot] {
        let entries: [(BirdSpecies, Double, Double, Double, String, String)] = [
            (.heron, 0.0021, -0.0032, 0.2, user.id, "A heron was spotted by the lake, calmly indifferent."),
            (.robin, -0.0012, 0.0018, 3, user.id, "Robin singing a song on a park bench."),
            (.swan, 0.0030, 0.0041, 7, "birder-2", "Two swans gliding past the bridge."),
            (.pigeon, -0.0026, -0.0015, 12, "birder-3", "A pigeon eating a sandwich in front of a bus stop."),
            (.kingfisher, 0.0009, 0.0052, 26, user.id, "Kingfisher diving next to the canal, extremely excited."),
            (.owl, -0.0034, 0.0037, 30, "birder-2", "Sleepy owl under a tree, suspiciously quiet."),
            (.falcon, 0.0038, -0.0049, 48, "birder-3", "Falcon on the roof of a building."),
            (.duck, -0.0005, -0.0058, 72, user.id, "A duck wearing a tiny hat. Probably."),
        ]

        return entries.enumerated().map { index, entry in
            let (species, latOffset, lonOffset, daysAgo, userID, note) = entry
            return BirdSpot(
                id: "demo-\(index)",
                species: species,
                date: now.addingTimeInterval(-daysAgo * 86_400),
                location: Location(
                    latitude: location.latitude + latOffset,
                    longitude: location.longitude + lonOffset
                ),
                note: note,
                userID: userID
            )
        }
    }
}
