//
//  AuthService.swift
//  Birdie
//
//  Created by dmu mac 33 on 12/05/2025.
//

import FirebaseAuth
import Foundation

struct AuthService: AuthServiceProtocol {

    @MainActor
    func createUser(
        _ photoURL: String?,
        _ displayname: String,
        _ email: String,
        _ password: String,
    )
        async throws -> User
    {
        let result = try await Auth.auth().createUser(
            withEmail: email,
            password: password
        )
        await updateProfile(
            result.user,
            displayName: displayname,
            photoURL: photoURL
        )
        return result.user
    }

    @MainActor
    func signIn(_ email: String, _ password: String) async throws -> User
    {
        let result = try await Auth.auth().signIn(
            withEmail: email,
            password: password
        )
        return result.user
    }

    func signOut() throws {
        try Auth.auth().signOut()
    }

    func getCurrentUser() async -> User? {
            guard let user = Auth.auth().currentUser else { return nil }

            do {
                try await user.reload()
                return Auth.auth().currentUser
            } catch {
                print("Failed to reload user: \(error.localizedDescription)")
                return user
            }
        }

    //MARK: - User Profile functions

    func editProfile(
        displayName: String?,
        photoURL: String?,
        email: String?,
        password: String?
    ) async {
        guard let user = Auth.auth().currentUser else {
            print("No authenticated user found. How did you even get here?")
            return
        }

        await updateProfile(user, displayName: displayName, photoURL: photoURL)
        updateEmail(user, email: email)
        updatePassword(user, password: password)
    }

    private func updateProfile(
        _ user: User,
        displayName: String?,
        photoURL: String?
    ) async {
        let changeRequest = user.createProfileChangeRequest()
        var didChange = false

        if let name = displayName, !name.isEmpty {
            changeRequest.displayName = name
            didChange = true
        }

        if let photo = photoURL, let url = URL(string: photo), !photo.isEmpty {
            changeRequest.photoURL = url
            didChange = true
        }

        if didChange {
            changeRequest.commitChanges { error in
                if let error = error {
                    print(
                        "Failed to update profile: \(error.localizedDescription)"
                    )
                } else {
                    print("Profile updated successfully.")
                }
            }
        }
    }

    private func updateEmail(_ user: User, email: String?) {
        guard let email = email, !email.isEmpty else { return }

        user.sendEmailVerification(beforeUpdatingEmail: email) { error in
            if let error = error {
                print("Failed to update email: \(error.localizedDescription)")
            } else {
                print("Email updated successfully.")
            }
        }
    }

    private func updatePassword(_ user: User, password: String?) {
        guard let password = password, !password.isEmpty, password.count >= 6
        else { return }

        user.updatePassword(to: password) { error in
            if let error = error {
                print(
                    "Failed to update password: \(error.localizedDescription)"
                )
            } else {
                print("Password updated successfully.")
            }
        }
    }
    
    func manualPhotoSetter(from url: String) {
        guard let user = Auth.auth().currentUser else { return }
        
        guard let picURL = URL(string: url) else {
            print("Invalid URL string: \(url)")
            return
        }

        let changeRequest = user.createProfileChangeRequest()
        changeRequest.photoURL = picURL
        changeRequest.commitChanges { error in
            if let error = error {
                print("Failed to update photoURL: \(error.localizedDescription)")
            } else {
                print("Successfully updated photoURL")
            }
        }
    }

    

}
