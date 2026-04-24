//
//  AuthController.swift
//  Birdie
//
//  Created by dmu mac 33 on 12/05/2025.
//

import FirebaseAuth
import Foundation

@Observable
class AuthController {
    private var currentFIRUser: User?

    var isAuthenticated: Bool = false

    var currentUserID: String {
        if let userID = currentFIRUser?.uid {
            print("UserID for this user!: \(userID)")
            return userID
        } else {
            fatalError("No user logged in")
        }
    }

    private var authHandle: AuthStateDidChangeListenerHandle?

    func listenToAuthState() {
        authHandle = Auth.auth().addStateDidChangeListener { _, user in
            Task { @MainActor in
                self.currentFIRUser = user
                self.isAuthenticated = (user != nil)
            }
        }
    }

    @MainActor
    func signIn(with email: String, and password: String, ) async throws {
        do {
            self.currentFIRUser = try await AuthService.signIn(email, password)
        } catch {
            print("Error signing in: \(error.localizedDescription)")
        }
    }

    func signUp(
        as displayname: String,
        with email: String,
        and password: String
    ) async throws {
        do {
            _ = try await AuthService.createUser(
                nil,
                displayname,
                email,
                password
            )
            try AuthService.signOut()
        }
    }

    func signOut() {
        do {
            try AuthService.signOut()
        } catch let error {
            print("Error signing out: \(error.localizedDescription)")
        }
    }

}
