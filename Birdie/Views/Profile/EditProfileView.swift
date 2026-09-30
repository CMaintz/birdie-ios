//
//  EditProfileView.swift
//  Birdie
//
//  Created by dmu mac 33 on 14/05/2025.
//

import AlertToast
import SwiftUI

struct EditProfileView: View {
    @Environment(UserController.self) var userController
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var toastManager: ToastManager

    @State private var displayName: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Group {
                    CustomTextField("Display Name", text: $displayName)
                    CustomTextField("Email", text: $email, keyboardType: .emailAddress)
                    CustomSecureField("New Password", text: $password)
                    CustomSecureField("Confirm Password", text: $confirmPassword)
                }

                Button(action: {
                    Task {
                        await updateProfile()
                    }
                }) {
                    Text("Update Profile")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }

                Button("Cancel") {
                    dismiss()
                }
                .foregroundColor(.red)
                .padding(.top, 8)

                Spacer()
            }
            .padding()
            .navigationTitle("Edit Profile")
            .onAppear {
                displayName = userController.displayName ?? ""
                email = userController.email ?? ""
            }
        }
        .toast(isPresenting: $toastManager.show) {
            toastManager.alertToast
        }
    }

    private func updateProfile() async {
        guard let user = userController.currentUser else { return }

        let changes: ProfileChanges
        do {
            changes = try ProfileChanges.diff(
                from: user,
                displayName: displayName,
                email: email,
                password: password,
                confirmPassword: confirmPassword
            )
        } catch {
            showError(error)
            return
        }

        guard !changes.isEmpty else {
            toastManager.showToast(
                AlertToast(type: .error(.red), title: "No Changes", subTitle: "No changes were made to your profile.")
            )
            return
        }

        do {
            try await userController.updateProfile(changes)
        } catch {
            showError(error)
            return
        }

        let subTitle = changes.email == nil
            ? "Profile updated!"
            : "Profile updated. Check your inbox to confirm the new email."
        toastManager.showToast(AlertToast(type: .complete(.green), title: "Success!", subTitle: subTitle))
        dismiss()
    }

    private func showError(_ error: Error) {
        toastManager.showToast(
            AlertToast(type: .error(.red), title: "Error!", subTitle: error.localizedDescription)
        )
    }
}

// MARK: - Custom Input Views

struct CustomTextField: View {
    var placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        TextField(placeholder, text: $text)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10).stroke(
                    Color.gray.opacity(0.3)
                )
            )
            .keyboardType(keyboardType)
            .autocapitalization(.none)
    }

    init(
        _ placeholder: String,
        text: Binding<String>,
        keyboardType: UIKeyboardType = .default
    ) {
        self.placeholder = placeholder
        self._text = text
        self.keyboardType = keyboardType
    }
}

struct CustomSecureField: View {
    var placeholder: String
    @Binding var text: String

    var body: some View {
        SecureField(placeholder, text: $text)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10).stroke(
                    Color.gray.opacity(0.3)
                )
            )
            .autocapitalization(.none)
    }

    init(_ placeholder: String, text: Binding<String>) {
        self.placeholder = placeholder
        self._text = text
    }
}

#Preview {
    EditProfileView()
        .withDemoEnvironment()
}
