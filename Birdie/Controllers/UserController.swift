//
//  UserController.swift
//  Birdie
//
//  Created by dmu mac 33 on 12/05/2025.
//

import Foundation

@Observable
class UserController : UserControllerProtocol {
    var currentUser: BirdieUser?
    private let authService: AuthServiceProtocol

    init(authService: AuthServiceProtocol = AuthService()) {
        self.authService = authService
    }

    func loadCurrentUser() {
        Task {
            guard let user = await authService.getCurrentUser() else {
                currentUser = nil
                return
            }

            currentUser = BirdieUser(
                id: user.uid,
                email: user.email ?? "",
                displayName: user.displayName ?? "Unnamed",
                imageURL: user.photoURL?.absoluteString
            )
            print(user.photoURL?.relativeString ?? "Uh oh")
            print(user.photoURL?.absoluteString ?? "Errrm")
        }
    }


    // MARK: - Update Methods

    func updateDisplayName(_ name: String) async throws {
        await authService.editProfile(
            displayName: name,
            photoURL: nil,
            email: nil,
            password: nil
        )
        loadCurrentUser()
    }

    func updatePhotoURL(_ urlString: String) async throws {
        await authService.editProfile(
            displayName: nil,
            photoURL: urlString,
            email: nil,
            password: nil
        )
        loadCurrentUser()
    }

    func updateEmail(_ newEmail: String) async throws {
        await authService.editProfile(
            displayName: nil,
            photoURL: nil,
            email: newEmail,
            password: nil
        )
        loadCurrentUser()
    }

    func updatePassword(_ newPassword: String) async throws {
        await authService.editProfile(
            displayName: nil,
            photoURL: nil,
            email: nil,
            password: newPassword
        )
    }

    //MARK: - Getters
    func getDisplayName() -> String? {
        currentUser?.displayName
    }

    func getUserID() -> String? {
        return currentUser?.id
    }

    func getEmail() -> String? {
        return currentUser?.email
    }

    func getPhotoURL() -> URL? {
        return currentUser?.profileImageURL
    }
}
