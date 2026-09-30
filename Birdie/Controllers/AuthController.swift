//
//  AuthController.swift
//  Birdie
//
//  Created by dmu mac 33 on 12/05/2025.
//

import Foundation

@Observable
final class AuthController {
    private(set) var currentUser: BirdieUser?

    var isAuthenticated: Bool { currentUser != nil }
    var currentUserID: String? { currentUser?.id }

    private let authService: AuthServiceProtocol

    init(authService: AuthServiceProtocol) {
        self.authService = authService
        self.currentUser = authService.currentUser
    }

    func listenToAuthState() {
        authService.observeAuthState { [weak self] user in
            self?.currentUser = user
        }
    }

    func signIn(email: String, password: String) async throws {
        try FormValidation.validateLogin(email: email, password: password)
        do {
            currentUser = try await authService.signIn(email: email.trimmed, password: password)
        } catch {
            Log.auth.error("Sign-in failed: \(error.localizedDescription, privacy: .public)")
            throw error
        }
    }

    /// Creates the account, then signs out again so the user logs in explicitly.
    func signUp(
        displayName: String,
        email: String,
        password: String,
        confirmPassword: String
    ) async throws {
        try FormValidation.validateRegistration(
            displayName: displayName,
            email: email,
            password: password,
            confirmPassword: confirmPassword
        )
        do {
            _ = try await authService.createUser(
                displayName: displayName.trimmed,
                email: email.trimmed,
                password: password,
                photoURL: nil
            )
            try authService.signOut()
            currentUser = nil
        } catch {
            Log.auth.error("Sign-up failed: \(error.localizedDescription, privacy: .public)")
            throw error
        }
    }

    func signOut() throws {
        do {
            try authService.signOut()
            currentUser = nil
        } catch {
            Log.auth.error("Sign-out failed: \(error.localizedDescription, privacy: .public)")
            throw error
        }
    }
}
