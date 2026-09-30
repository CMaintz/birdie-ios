import Foundation

protocol AuthServiceProtocol: AnyObject {
    var currentUser: BirdieUser? { get }

    /// Calls `onChange` immediately with the current user and again on every sign-in/sign-out.
    func observeAuthState(_ onChange: @escaping (BirdieUser?) -> Void)

    func createUser(
        displayName: String,
        email: String,
        password: String,
        photoURL: URL?
    ) async throws -> BirdieUser

    func signIn(email: String, password: String) async throws -> BirdieUser

    func signOut() throws

    func reloadCurrentUser() async throws -> BirdieUser?

    func updateProfile(_ changes: ProfileChanges) async throws
}

enum AuthServiceError: LocalizedError, Equatable {
    case notSignedIn
    case invalidCredentials
    case emailAlreadyInUse

    var errorDescription: String? {
        switch self {
        case .notSignedIn: "You need to be signed in to do that."
        case .invalidCredentials: "Wrong email or password."
        case .emailAlreadyInUse: "An account with that email already exists."
        }
    }
}
