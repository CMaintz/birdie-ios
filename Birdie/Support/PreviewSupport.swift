import SwiftUI

extension View {
    /// Injects controllers backed by in-memory demo services, for SwiftUI previews.
    func withDemoEnvironment() -> some View {
        let services = AppServices.demo()
        let authController = AuthController(authService: services.auth)
        return self
            .environment(authController)
            .environment(UserController(authService: services.auth))
            .environment(BirdSpotController(repository: services.spots))
            .environment(LocationController(fixedLocation: services.fixedLocation))
            .environmentObject(ToastManager())
    }
}
