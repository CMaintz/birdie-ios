import FirebaseCore
import Foundation

/// Composition root: the concrete services the controllers are built with.
struct AppServices {
    let mode: AppMode
    let auth: AuthServiceProtocol
    let spots: SpotRepositoryProtocol
    /// When set, `LocationController` reports this instead of using Core Location.
    let fixedLocation: Location?

    static func make(for mode: AppMode) -> AppServices {
        switch mode {
        case .firebase:
            FirebaseApp.configure()
            return AppServices(
                mode: .firebase,
                auth: FirebaseAuthService(),
                spots: FirestoreSpotRepository(),
                fixedLocation: nil
            )
        case .demo:
            return demo()
        }
    }

    static func demo(now: Date = Date()) -> AppServices {
        AppServices(
            mode: .demo,
            auth: InMemoryAuthService(
                accounts: [(DemoData.user, DemoData.password)],
                signedInAs: DemoData.user
            ),
            spots: InMemorySpotRepository(spots: DemoData.spots(relativeTo: now)),
            fixedLocation: DemoData.location
        )
    }
}
