import Foundation
import Testing
@testable import Birdie

struct AuthControllerTests {
    private let alice = BirdieUser(id: "alice", email: "alice@birdie.dk", displayName: "Alice", imageURL: nil)

    private func makeController(signedIn: Bool = false) -> (AuthController, InMemoryAuthService) {
        let service = InMemoryAuthService(accounts: [(alice, "secret1")], signedInAs: signedIn ? alice : nil)
        let controller = AuthController(authService: service)
        controller.listenToAuthState()
        return (controller, service)
    }

    @Test func startsWithTheServicesCurrentUser() {
        let (controller, _) = makeController(signedIn: true)
        #expect(controller.isAuthenticated)
        #expect(controller.currentUserID == "alice")
    }

    @Test func signInWithValidCredentials() async throws {
        let (controller, _) = makeController()
        try await controller.signIn(email: " alice@birdie.dk ", password: "secret1")
        #expect(controller.currentUser == alice)
    }

    @Test func signInWithWrongPasswordThrowsAndStaysSignedOut() async {
        let (controller, _) = makeController()
        await #expect(throws: AuthServiceError.invalidCredentials) {
            try await controller.signIn(email: "alice@birdie.dk", password: "wrong")
        }
        #expect(!controller.isAuthenticated)
    }

    @Test func signInValidatesBeforeCallingTheService() async {
        let (controller, _) = makeController()
        await #expect(throws: FormError.missingCredentials) {
            try await controller.signIn(email: "", password: "")
        }
    }

    @Test func signUpCreatesTheAccountAndSignsOutAgain() async throws {
        let (controller, service) = makeController()
        try await controller.signUp(
            displayName: "Bob", email: "bob@birdie.dk", password: "hunter22", confirmPassword: "hunter22"
        )
        #expect(!controller.isAuthenticated)

        let bob = try await service.signIn(email: "bob@birdie.dk", password: "hunter22")
        #expect(bob.displayName == "Bob")
    }

    @Test func signUpWithExistingEmailFails() async {
        let (controller, _) = makeController()
        await #expect(throws: AuthServiceError.emailAlreadyInUse) {
            try await controller.signUp(
                displayName: "Alice 2", email: "alice@birdie.dk", password: "secret1", confirmPassword: "secret1"
            )
        }
    }

    @Test func signOutClearsTheUser() throws {
        let (controller, _) = makeController(signedIn: true)
        try controller.signOut()
        #expect(!controller.isAuthenticated)
        #expect(controller.currentUserID == nil)
    }

    @Test func followsAuthStateChangesFromTheService() async throws {
        let (controller, service) = makeController()
        _ = try await service.signIn(email: "alice@birdie.dk", password: "secret1")
        #expect(controller.currentUser == alice)

        try service.signOut()
        #expect(controller.currentUser == nil)
    }
}

struct UserControllerTests {
    private let alice = BirdieUser(
        id: "alice", email: "alice@birdie.dk", displayName: "Alice", imageURL: "https://example.com/a.png"
    )

    @Test func exposesTheCurrentUsersDetails() {
        let controller = UserController(
            authService: InMemoryAuthService(accounts: [(alice, "secret1")], signedInAs: alice)
        )
        #expect(controller.userID == "alice")
        #expect(controller.displayName == "Alice")
        #expect(controller.email == "alice@birdie.dk")
        #expect(controller.photoURL == URL(string: "https://example.com/a.png"))
    }

    @Test func isEmptyWhenSignedOut() {
        let controller = UserController(authService: InMemoryAuthService())
        #expect(controller.currentUser == nil)
        #expect(controller.photoURL == nil)
    }

    @Test func updateProfileAppliesChangesAndReloads() async throws {
        let service = InMemoryAuthService(accounts: [(alice, "secret1")], signedInAs: alice)
        let controller = UserController(authService: service)

        try await controller.updateProfile(ProfileChanges(displayName: "Alice B", email: "ab@birdie.dk"))

        #expect(controller.displayName == "Alice B")
        #expect(controller.email == "ab@birdie.dk")
    }

    @Test func updateProfileWhenSignedOutThrows() async {
        let controller = UserController(authService: InMemoryAuthService())
        await #expect(throws: AuthServiceError.notSignedIn) {
            try await controller.updateProfile(ProfileChanges(displayName: "Nobody"))
        }
    }

    @Test func emptyChangesAreANoOp() async throws {
        let controller = UserController(authService: InMemoryAuthService())
        try await controller.updateProfile(ProfileChanges())
        #expect(controller.currentUser == nil)
    }
}

struct BirdieUserTests {
    @Test func profileImageURLIgnoresEmptyStrings() {
        #expect(BirdieUser(id: "1", email: "", displayName: "", imageURL: "").profileImageURL == nil)
        #expect(BirdieUser(id: "1", email: "", displayName: "", imageURL: nil).profileImageURL == nil)
        #expect(
            BirdieUser(id: "1", email: "", displayName: "", imageURL: "https://x.dk/p.png").profileImageURL
                == URL(string: "https://x.dk/p.png")
        )
    }
}
