//
//  RegistrationView.swift
//  Birdie
//
//  Created by dmu mac 33 on 12/05/2025.
//

import AlertToast
import SwiftUI

struct RegistrationView: View {
    @Environment(AuthController.self) private var authController
    @EnvironmentObject var toastManager: ToastManager
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @Binding var isSignUp: Bool
    @State private var displayName = ""

    var body: some View {
        VStack {
            Text("Create User")
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

            TextField("DisplayName", text: $displayName)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .textContentType(.username)

            SecureField("Confirm Password", text: $confirmPassword)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .textContentType(.password)
                .keyboardType(.default)
                .textInputAutocapitalization(.never)

            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .textContentType(.password)
                .keyboardType(.default)
                .padding()
                .textInputAutocapitalization(.never)

            Button(action: {
                handleAuth()
            }) {
                Text("Create User")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()

            Button(action: {
                password = ""
                confirmPassword = ""
                isSignUp.toggle()
            }) {
                Text("Already have an account? Sign in")
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
        guard !email.isEmpty, !password.isEmpty, !displayName.isEmpty else {
            toastManager.showToast(AlertToast(
                displayMode: .banner(.slide),
                type: .error(.red),
                title: "Error",
                subTitle: "Name, Email and password required"
            ))
            return
        }

        guard password == confirmPassword else {
            toastManager.showToast(AlertToast(
                displayMode: .banner(.slide),
                type: .error(.red),
                title: "Error",
                subTitle: "Passwords do not match"
            ))
            return
        }

        Task {
            do {
                try await authController.signUp(
                    as: displayName,
                    with: email,
                    and: password
                ) //TODO: the darn thing should be timed to wait or some shizzle
                isSignUp = false
                toastManager.showToast(AlertToast(
                    type: .complete(.green),
                    title: "Success!",
                    subTitle: "Your user has been created"
                ))
            } catch {
                toastManager.showToast(AlertToast(
                    type: .error(.red),
                    title: "Error!",
                    subTitle: error.localizedDescription
                ))
            }
        }
    }
}

#Preview {
    RegistrationView(isSignUp: .constant(true))
        .environment(AuthController())
        .environmentObject(ToastManager())
}
