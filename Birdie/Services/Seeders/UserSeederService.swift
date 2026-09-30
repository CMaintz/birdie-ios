//
//  UserSeederService.swift
//  Birdie
//
//  Created by dmu mac 33 on 12/05/2025.
//

#if DEBUG
import Foundation

/// Debug-only: creates sample Firebase Auth users (from randomuser.me) with random sightings.
/// Never runs unless explicitly requested, see `DebugSeeding`.
struct UserSeederService {
    private static let seedingKey = "hasSeededUsers"

    let auth: AuthServiceProtocol
    let spotSeeder: SpotSeederService
    var userDefaults: UserDefaults = .standard

    func seedUsersIfNeeded() async {
        guard !userDefaults.bool(forKey: Self.seedingKey) else {
            Log.seeding.info("Users have already been seeded")
            return
        }
        do {
            let randomUsers = try await fetchRandomUsers()
            try await seedUsers(from: randomUsers)
            userDefaults.set(true, forKey: Self.seedingKey)
        } catch {
            Log.seeding.error("Seeding users failed: \(error.localizedDescription, privacy: .public)")
        }
    }

    func resetSeedingFlag() {
        userDefaults.set(false, forKey: Self.seedingKey)
    }

    // MARK: - Private helpers

    private func fetchRandomUsers() async throws -> [RandomUser] {
        let url = URL(string: "https://randomuser.me/api/?results=10")!

        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 10
        sessionConfig.timeoutIntervalForResource = 15
        let session = URLSession(configuration: sessionConfig)

        var lastError: Error?
        for attempt in 1...3 {
            do {
                let (data, response) = try await session.data(from: url)
                if let httpResponse = response as? HTTPURLResponse,
                    !(200...299).contains(httpResponse.statusCode)
                {
                    throw URLError(.badServerResponse)
                }
                return try JSONDecoder().decode(RandomUserResponse.self, from: data).results
            } catch {
                lastError = error
                Log.seeding.notice("randomuser.me attempt \(attempt) failed")
                if attempt < 3 {
                    try? await Task.sleep(for: .seconds(pow(2.0, Double(attempt))))
                }
            }
        }
        throw lastError ?? URLError(.timedOut)
    }

    /// Sequential on purpose: each `createUser` signs the new account in.
    private func seedUsers(from randomUsers: [RandomUser]) async throws {
        var allSpots: [BirdSpot] = []
        var errors: [Error] = []

        for randomUser in randomUsers {
            do {
                var password = randomUser.login.password
                if password.count < FormValidation.minimumPasswordLength {
                    password += String(Int.random(in: 100...999))
                }
                let avatarURL = URL(
                    string: "https://api.dicebear.com/6.x/avataaars/png?seed=\(randomUser.login.uuid)"
                )
                let createdUser = try await auth.createUser(
                    displayName: randomUser.fullName,
                    email: randomUser.email,
                    password: password,
                    photoURL: avatarURL
                )
                allSpots += spotSeeder.randomSpots(for: createdUser.id)
                try auth.signOut()
                Log.seeding.info("Created seed user \(createdUser.id, privacy: .private)")
            } catch {
                errors.append(error)
                Log.seeding.error("Creating seed user failed: \(error.localizedDescription, privacy: .public)")
            }
        }

        try await spotSeeder.repository.addSpots(allSpots)
        Log.seeding.info(
            "Seeding completed: \(randomUsers.count - errors.count) succeeded, \(errors.count) failed"
        )

        if errors.count == randomUsers.count, let firstError = errors.first {
            throw firstError
        }
    }
}

/// Opt-in switch for Firebase seeding: pass `--seed-firebase` as a launch argument
/// or set `BIRDIE_SEED=1` in the scheme's environment. Debug builds only.
enum DebugSeeding {
    static let launchArgument = "--seed-firebase"

    static var isRequested: Bool {
        ProcessInfo.processInfo.arguments.contains(launchArgument)
            || ProcessInfo.processInfo.environment["BIRDIE_SEED"] == "1"
    }

    static func runIfRequested(with services: AppServices) async {
        guard isRequested, services.mode == .firebase else { return }
        let spotSeeder = SpotSeederService(repository: services.spots)
        await UserSeederService(auth: services.auth, spotSeeder: spotSeeder).seedUsersIfNeeded()
    }
}
#endif
