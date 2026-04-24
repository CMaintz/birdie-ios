//
//  LoginView.swift
//  Birdie
//
//  Created by dmu mac 33 on 12/05/2025.
//

import AlertToast
import SwiftUI

struct LoginView: View {
    @Environment(AuthController.self) private var authController
    @EnvironmentObject var toastManager: ToastManager
    @State private var email = ""
    @State private var password = ""
    @State private var displayName = ""
    @Binding var isSignUp: Bool

    var body: some View {
        VStack {
            Text("Sign In")
                .font(.largeTitle)
                .bold()
                .padding()

            TextField("Email", text: $email)
                .textContentType(.emailAddress)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .keyboardType(.emailAddress)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .textContentType(.password)
                .keyboardType(.default)
                .padding()
                .textInputAutocapitalization(.never)

            Button(action: {
                handleAuth()
            }) {
                Text("Sign In")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()

            Button(action: {
                password = ""
                isSignUp.toggle()
            }) {
                Text("Don't have an account? Sign up")
                    .foregroundColor(.blue)
            }
            .padding()
        }
        .padding()
        .toast(isPresenting: $toastManager.show) {
            toastManager.alertToast
        }
    }

    private func handleAuth() {
        guard !email.isEmpty, !password.isEmpty else {
            toastManager.showToast(AlertToast(
                displayMode: .banner(.slide),
                type: .error(.red),
                title: "Error",
                subTitle: "Email and password required"
            ))
            return
        }

        Task {
            do {
                try await authController.signIn(with: email, and: password)
                toastManager.showToast(AlertToast(
                    displayMode: .hud,
                    type: .complete(.green),
                    title: "Logged In!"
                ))
            } catch {
                toastManager.showToast(AlertToast(
                    displayMode: .banner(.slide),
                    type: .error(.red),
                    title: "Error!",
                    subTitle: error.localizedDescription
                ))
            }
        }
    }
}

#Preview {
    LoginView(isSignUp: .constant(false))
        .environment(AuthController())
        .environmentObject(ToastManager())
}
