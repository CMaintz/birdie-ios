//
//  UserController.swift
//  Birdie
//
//  Created by dmu mac 33 on 12/05/2025.
//

import Foundation

@Observable
final class UserController {
    private(set) var currentUser: BirdieUser?

    private let authService: AuthServiceProtocol

    init(authService: AuthServiceProtocol) {
        self.authService = authService
        self.currentUser = authService.currentUser
    }

    var userID: String? { currentUser?.id }
    var displayName: String? { currentUser?.displayName }
    var email: String? { currentUser?.email }
    var photoURL: URL? { currentUser?.profileImageURL }

    /// Refreshes the profile from the backend, falling back to the cached user on failure.
    func loadCurrentUser() async {
        do {
            currentUser = try await authService.reloadCurrentUser()
        } catch {
            Log.auth.error("Reloading user failed: \(error.localizedDescription, privacy: .public)")
            currentUser = authService.currentUser
        }
    }

    func updateProfile(_ changes: ProfileChanges) async throws {
        guard !changes.isEmpty else { return }
        do {
            try await authService.updateProfile(changes)
        } catch {
            Log.auth.error("Profile update failed: \(error.localizedDescription, privacy: .public)")
            throw error
        }
        await loadCurrentUser()
    }
}
