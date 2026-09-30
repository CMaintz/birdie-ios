import Foundation

/// Auth backend kept entirely in memory. Backs demo mode, previews and tests.
final class InMemoryAuthService: AuthServiceProtocol {
    private var accounts: [String: (user: BirdieUser, password: String)] = [:]
    private var listeners: [(BirdieUser?) -> Void] = []

    private(set) var currentUser: BirdieUser? {
        didSet { listeners.forEach { $0(currentUser) } }
    }

    init(accounts: [(BirdieUser, String)] = [], signedInAs user: BirdieUser? = nil) {
        for (account, password) in accounts {
            self.accounts[account.email.lowercased()] = (account, password)
        }
        currentUser = user
    }

    func observeAuthState(_ onChange: @escaping (BirdieUser?) -> Void) {
        listeners.append(onChange)
        onChange(currentUser)
    }

    func createUser(
        displayName: String,
        email: String,
        password: String,
        photoURL: URL?
    ) async throws -> BirdieUser {
        let key = email.lowercased()
        guard accounts[key] == nil else { throw AuthServiceError.emailAlreadyInUse }
        let user = BirdieUser(
            id: UUID().uuidString,
            email: email,
            displayName: displayName,
            imageURL: photoURL?.absoluteString
        )
        accounts[key] = (user, password)
        currentUser = user
        return user
    }

    func signIn(email: String, password: String) async throws -> BirdieUser {
        guard let account = accounts[email.lowercased()], account.password == password else {
            throw AuthServiceError.invalidCredentials
        }
        currentUser = account.user
        return account.user
    }

    func signOut() throws {
        currentUser = nil
    }

    func reloadCurrentUser() async throws -> BirdieUser? {
        currentUser
    }

    func updateProfile(_ changes: ProfileChanges) async throws {
        guard let user = currentUser, let account = accounts[user.email.lowercased()] else {
            throw AuthServiceError.notSignedIn
        }
        let updated = BirdieUser(
            id: user.id,
            email: changes.email ?? user.email,
            displayName: changes.displayName ?? user.displayName,
            imageURL: changes.photoURL?.absoluteString ?? user.imageURL
        )
        accounts[user.email.lowercased()] = nil
        accounts[updated.email.lowercased()] = (updated, changes.password ?? account.password)
        currentUser = updated
    }
}
