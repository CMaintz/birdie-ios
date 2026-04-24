//
//  RootView.swift
//  Birdie
//
//  Created by dmu mac 33 on 13/05/2025.
//

import AlertToast
import SwiftUI

struct RootView: View {
    @State var birdSpotController: any BirdSpotControllerProtocol
    @State var userController: any UserControllerProtocol
    @State var locationController: any LocationServiceProtocol

    @State var isRegistration: Bool = false
    @State private var hasSplashed: Bool = false

    @Environment(AuthController.self) private var authController
    @EnvironmentObject var toastManager: ToastManager

    init(
        birdSpotController: any BirdSpotControllerProtocol = BirdSpotController(),
        userController: any UserControllerProtocol = UserController(),
        locationController: any LocationServiceProtocol = LocationController()
    ) {
        self.birdSpotController = birdSpotController
        self.userController = userController
        self.locationController = locationController
    }
    
    var body: some View {
            ZStack {
                if !authController.isAuthenticated {
                    if isRegistration {
                        RegistrationView(isSignUp: $isRegistration)
                    } else {
                        LoginView(isSignUp: $isRegistration)
                    }
                } else {
                    if !hasSplashed {
                       
                        SplashView {
                            Task { @MainActor in
                                withAnimation {
                                    hasSplashed = true
                                }
                            }
                        }
                    } else {
                        MainTabView()
                            .environment(birdSpotController)
                            .environment(userController)
                            .environment(locationController)
                    }
                }
            }
            .toast(isPresenting: $toastManager.show) {
                toastManager.alertToast
            }
            .onChange(of: authController.isAuthenticated) { _, newValue in
                if newValue == true {
                    userController.loadCurrentUser()
                    hasSplashed = false
                } else {
                    hasSplashed = false
                }
            }
        }
    }
