import Foundation

/// Which backend the app talks to.
enum AppMode: Equatable {
    /// Real Firebase Auth + Firestore. Requires `GoogleService-Info.plist`.
    case firebase
    /// In-memory services with sample data; no network or Firebase config needed.
    /// Used by `--demo`, unit tests and SwiftUI previews.
    case demo

    static let demoLaunchArgument = "--demo"

    static func resolve(
        arguments: [String] = ProcessInfo.processInfo.arguments,
        environment: [String: String] = ProcessInfo.processInfo.environment
    ) -> AppMode {
        if arguments.contains(demoLaunchArgument) { return .demo }
        if environment["XCTestConfigurationFilePath"] != nil
            || environment["XCTestBundlePath"] != nil
            || environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
        {
            return .demo
        }
        return .firebase
    }
}

enum LaunchOptions {
    /// Value following `--tab` (e.g. `--tab map`), used to open a specific tab for screenshots.
    static func initialTab(arguments: [String] = ProcessInfo.processInfo.arguments) -> String? {
        guard let index = arguments.firstIndex(of: "--tab"), arguments.indices.contains(index + 1)
        else { return nil }
        return arguments[index + 1]
    }

    static var skipsSplash: Bool {
        ProcessInfo.processInfo.arguments.contains("--skip-splash")
    }
}
