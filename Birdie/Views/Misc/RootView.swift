//
//  RootView.swift
//  Birdie
//
//  Created by dmu mac 33 on 13/05/2025.
//

import AlertToast
import SwiftUI

struct RootView: View {
    @Environment(AuthController.self) private var authController
    @Environment(UserController.self) private var userController
    @EnvironmentObject var toastManager: ToastManager

    @State private var isRegistration = false
    @State private var hasSplashed = LaunchOptions.skipsSplash

    var body: some View {
        ZStack {
            if !authController.isAuthenticated {
                if isRegistration {
                    RegistrationView(isSignUp: $isRegistration)
                } else {
                    LoginView(isSignUp: $isRegistration)
                }
            } else if !hasSplashed {
                SplashView {
                    withAnimation {
                        hasSplashed = true
                    }
                }
            } else {
                MainTabView()
            }
        }
        .toast(isPresenting: $toastManager.show) {
            toastManager.alertToast
        }
        .onChange(of: authController.isAuthenticated) { _, isAuthenticated in
            hasSplashed = LaunchOptions.skipsSplash
            if isAuthenticated {
                Task { await userController.loadCurrentUser() }
            }
        }
    }
}

#Preview {
    RootView().withDemoEnvironment()
}
