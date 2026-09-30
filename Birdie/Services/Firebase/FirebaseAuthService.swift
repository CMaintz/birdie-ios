//
//  FirebaseAuthService.swift
//  Birdie
//
//  Created by dmu mac 33 on 12/05/2025.
//

import FirebaseAuth
import Foundation

final class FirebaseAuthService: AuthServiceProtocol {
    private var authHandle: AuthStateDidChangeListenerHandle?

    deinit {
        if let authHandle {
            Auth.auth().removeStateDidChangeListener(authHandle)
        }
    }

    var currentUser: BirdieUser? {
        Auth.auth().currentUser.map(BirdieUser.init(firebaseUser:))
    }

    func observeAuthState(_ onChange: @escaping (BirdieUser?) -> Void) {
        if let authHandle {
            Auth.auth().removeStateDidChangeListener(authHandle)
        }
        authHandle = Auth.auth().addStateDidChangeListener { _, user in
            onChange(user.map(BirdieUser.init(firebaseUser:)))
        }
    }

    func createUser(
        displayName: String,
        email: String,
        password: String,
        photoURL: URL?
    ) async throws -> BirdieUser {
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        let changeRequest = result.user.createProfileChangeRequest()
        changeRequest.displayName = displayName
        if let photoURL {
            changeRequest.photoURL = photoURL
        }
        try await changeRequest.commitChanges()
        return BirdieUser(firebaseUser: result.user)
    }

    func signIn(email: String, password: String) async throws -> BirdieUser {
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        return BirdieUser(firebaseUser: result.user)
    }

    func signOut() throws {
        try Auth.auth().signOut()
    }

    func reloadCurrentUser() async throws -> BirdieUser? {
        guard let user = Auth.auth().currentUser else { return nil }
        try await user.reload()
        return currentUser
    }

    func updateProfile(_ changes: ProfileChanges) async throws {
        guard let user = Auth.auth().currentUser else { throw AuthServiceError.notSignedIn }

        if changes.displayName != nil || changes.photoURL != nil {
            let changeRequest = user.createProfileChangeRequest()
            if let displayName = changes.displayName {
                changeRequest.displayName = displayName
            }
            if let photoURL = changes.photoURL {
                changeRequest.photoURL = photoURL
            }
            try await changeRequest.commitChanges()
        }
        if let email = changes.email {
            // Firebase only switches the address after the user confirms the verification mail.
            try await user.sendEmailVerification(beforeUpdatingEmail: email)
        }
        if let password = changes.password {
            try await user.updatePassword(to: password)
        }
    }
}

extension BirdieUser {
    init(firebaseUser user: User) {
        self.init(
            id: user.uid,
            email: user.email ?? "",
            displayName: user.displayName ?? "Unnamed",
            imageURL: user.photoURL?.absoluteString
        )
    }
}
