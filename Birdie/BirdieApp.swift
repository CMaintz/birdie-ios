//
//  BirdieApp.swift
//  Birdie
//
//  Created by dmu mac 33 on 12/05/2025.
//

import SwiftUI

@main
struct BirdieApp: App {
    private let services: AppServices

    @State private var authController: AuthController
    @State private var userController: UserController
    @State private var spotController: BirdSpotController
    @State private var locationController: LocationController
    @StateObject private var toastManager = ToastManager()

    init() {
        let services = AppServices.make(for: AppMode.resolve())
        self.services = services
        _authController = State(initialValue: AuthController(authService: services.auth))
        _userController = State(initialValue: UserController(authService: services.auth))
        _spotController = State(initialValue: BirdSpotController(repository: services.spots))
        _locationController = State(
            initialValue: LocationController(fixedLocation: services.fixedLocation)
        )
        Log.app.info("Starting in \(String(describing: services.mode), privacy: .public) mode")
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(authController)
                .environment(userController)
                .environment(spotController)
                .environment(locationController)
                .environmentObject(toastManager)
                .onAppear {
                    authController.listenToAuthState()
                }
                .task {
                    #if DEBUG
                    await DebugSeeding.runIfRequested(with: services)
                    #endif
                }
        }
    }
}
