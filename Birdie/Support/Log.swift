import OSLog

enum Log {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "Birdie"

    static let app = Logger(subsystem: subsystem, category: "app")
    static let auth = Logger(subsystem: subsystem, category: "auth")
    static let spots = Logger(subsystem: subsystem, category: "spots")
    static let location = Logger(subsystem: subsystem, category: "location")
    static let seeding = Logger(subsystem: subsystem, category: "seeding")
}
