//
//  BirdieApp.swift
//  Birdie
//
//  Created by dmu mac 33 on 12/05/2025.
//

import Firebase
import SwiftUI

@main
struct BirdieApp: App {
    //Use albert.madsen@example.com - password: script
    
    // Service registrations
    @State private var authService: AuthServiceProtocol
    @State private var spotRepository: SpotRepository
    
    // Controllers using those services
    @State private var authController: AuthController
    @State private var userController: UserController
    @State private var toastManager: ToastManager


    init() {
        FirebaseApp.configure()
        
        // Create services
        let authService = AuthService()
        let spotRepository = FirestoreService()
        
        // Create controllers with dependencies
        self.authService = authService
        self.spotRepository = spotRepository
        self.authController = AuthController(authService: authService)
        self.userController = UserController(authService: authService)
        self.toastManager = ToastManager()
    }

    var body: some Scene {
        WindowGroup {
            RootView(
                birdSpotController: BirdSpotController(repository: spotRepository),
                userController: userController,
                locationController: LocationController()
            )
            .environment(authController)
            .environmentObject(toastManager)
                .task {

                    //UserSeederService.resetSeedingFlag()
                    await UserSeederService.seedUsersIfNeeded()
                    //await SpotSeederService.createRegionalBirdSpots(for: ["IpUS8cPN7wPhXtdmlk5u2aoyeOK2", "LS1Id3a637QKDd5LqOGozWA1MhA3", "iIw9Xi13Ifg0tZ7MiWKDF9hSStp2","4njGzSrUGXMNVHI6abYz2ZZ5Uog2","nJ66pGKkd4dpj3BMc8WnPGakgR42","tIJAmfDTmGNnHiHoVEJ7Zn6YJUd2"])
                }
                .onAppear {
                    authController.listenToAuthState()
                }
        }
    }
}
