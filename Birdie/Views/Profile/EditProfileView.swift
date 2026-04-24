//
//  EditProfileView.swift
//  Birdie
//
//  Created by dmu mac 33 on 14/05/2025.
//

import AlertToast
import SwiftUI

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
        NavigationView {
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
                displayName = userController.getDisplayName() ?? ""
                email = userController.getEmail() ?? ""
            }
        }
        .toast(isPresenting: $toastManager.show) {
            toastManager.alertToast
        }
    }

    private func updateProfile() async {
        guard let currentDisplayname = userController.getDisplayName(),
              let currentEmail = userController.getEmail() else {
            return
        }

        let trimmedDisplayName = displayName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)

        var updated = false
        var errorMessages: [String] = []

        if trimmedDisplayName != currentDisplayname, !trimmedDisplayName.isEmpty {
            do {
                try await userController.updateDisplayName(trimmedDisplayName)
                updated = true
            } catch {
                errorMessages.append("Display name: \(error.localizedDescription)")
            }
        }

        if trimmedEmail != currentEmail, !trimmedEmail.isEmpty {
            do {
                try await userController.updateEmail(trimmedEmail)
                updated = true
            } catch {
                errorMessages.append("Email: \(error.localizedDescription)")
            }
        }

        if !trimmedPassword.isEmpty {
            do {
                try await userController.updatePassword(trimmedPassword)
                updated = true
            } catch {
                errorMessages.append("Password: \(error.localizedDescription)")
            }
        }

        if updated {
            toastManager.showToast(
                AlertToast(type: .complete(.green), title: "Success!", subTitle: "Profile updated!")
            )
            dismiss()
        } else if !errorMessages.isEmpty {
            toastManager.showToast(
                AlertToast(type: .error(.red), title: "Error!", subTitle: errorMessages.joined(separator: "\n"))
            )
        } else {
            toastManager.showToast(
                AlertToast(type: .error(.red), title: "No Changes", subTitle: "No changes were made to your profile.")
            )
        }
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
        .environmentObject(ToastManager()).environment(UserController())
}
