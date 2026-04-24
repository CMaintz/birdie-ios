//
//  UserSeederService.swift
//  Birdie
//
//  Created by dmu mac 33 on 12/05/2025.
//

import Foundation

struct UserSeederService {

    private static let seedingKey = "hasSeededUsers"

    actor SeedCounter {
        var successCount = 0
        var failureCount = 0

        func incrementSuccess() {
            successCount += 1
        }

        func incrementFailure() {
            failureCount += 1
        }
    }

    static func seedUsersIfNeeded() async {
        // Check if we've already seeded users
        let hasSeededUsers = UserDefaults.standard.bool(forKey: seedingKey)
        if hasSeededUsers {
            print("Users have already been seeded.")
            return
        }

        do {
            // Fetch 10 random users from randomuser.me <3 this API
            let randomUsers = try await fetchRandomUsers()
            try await seedUsers(from: randomUsers)

            UserDefaults.standard.set(true, forKey: seedingKey)
            print("Users have been seeded.")
        } catch {
            print("Failed to seed users: \(error.localizedDescription)")
        }
    }

    static func resetSeedingFlag() {
        UserDefaults.standard.set(false, forKey: seedingKey)
        print(
            "Reset seeding key to:",
            UserDefaults.standard.bool(forKey: seedingKey)
        )
    }

    // MARK: - Private Helper Functions

    private static func fetchRandomUsers() async throws -> [RandomUser] {
        let url = URL(string: "https://randomuser.me/api/?results=10")!

        // Create a custom URLSession with timeouts - Resilience ya'll
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 10
        sessionConfig.timeoutIntervalForResource = 15
        let session = URLSession(configuration: sessionConfig)

        let request = URLRequest(url: url)

        // Retry logic
        var attempts = 0
        let maxAttempts = 3
        var lastError: Error?

        while attempts < maxAttempts {
            do {
                let (data, response) = try await session.data(for: request)

                // Add HTTP status code check
                if let httpResponse = response as? HTTPURLResponse,
                    !(200...299).contains(httpResponse.statusCode)
                {
                    throw URLError(.badServerResponse)
                }

                let decodedResponse = try JSONDecoder().decode(
                    RandomUserResponse.self,
                    from: data
                )
                return decodedResponse.results
            } catch {
                attempts += 1
                lastError = error

                if attempts < maxAttempts {
                    // Exponential backoff delay
                    let delay = pow(2.0, Double(attempts))
                    print("Retrying in \(Int(delay)) seconds...")
                }
            }
        }
        // If retries exhausted, throw the last error encountered else we throw a fallback error for unexpected shenanigans
        throw lastError ?? URLError(.timedOut)
    }

    static func seedUsers(from randomUsers: [RandomUser]) async throws {
        let counter = SeedCounter()
        let spotCollector = BirdSpotCollector()
        var errors: [Error] = []

        await withThrowingTaskGroup(of: Void.self) { group in
            for user in randomUsers {
                group.addTask {
                    do {
                        var password = user.login.password
                        if password.count < 6 {
                            password += String(Int.random(in: 100...999))
                        }

                        let diceBearURL = "https://api.dicebear.com/6.x/avataaars/png?seed=\(user.login.uuid)"


                        let createdUser = try await AuthService.createUser(
                            diceBearURL,
                            user.fullName,
                            user.email,
                            password
                        )

                        let userID = createdUser.uid
                        let spots = await SpotSeederService.seedBirdSpots(
                            for: userID
                        )
                        await spotCollector.append(spots)

                        print(
                            "Created user: \(user.email), password: \(password) UID: \(createdUser.uid)"
                        )
                        await counter.incrementSuccess()
                        try AuthService.signOut()
                    } catch {
                        print(
                            "Failed to create user: \(user.email), error: \(error.localizedDescription)"
                        )
                        await counter.incrementFailure()
                        errors.append(error)
                    }
                }
            }
        }

        let allSpots = await spotCollector.getAll()

        do {
            try await FirestoreService.addSpotsBatch(allSpots)
        } catch {
            print("Batch failed: \(error.localizedDescription)")
        }

        let successCount = await counter.successCount
        let failureCount = await counter.failureCount

        print(
            "Seeding completed: \(successCount) succeeded, \(failureCount) failed"
        )

        if successCount == 0 && !randomUsers.isEmpty {
            throw SeedingError.allUsersFailed(errors: errors)
        }
    }

    enum SeedingError: Error {
        case allUsersFailed(errors: [Error])
    }

    actor BirdSpotCollector {
        var spots: [BirdSpot] = []

        func append(_ newSpots: [BirdSpot]) {
            spots.append(contentsOf: newSpots)
        }

        func getAll() -> [BirdSpot] {
            return spots
        }
    }


}
