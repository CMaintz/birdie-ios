//
//  ProfileView.swift
//  Birdie
//
//  Created by dmu mac 33 on 13/05/2025.
//

import SwiftUI

struct ProfileView: View {
    @State private var showEdit = false

    @Environment(AuthController.self) var authController
    @Environment(UserController.self) var userController

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            VStack(spacing: 12) {
                UserImageView(
                    imageURL: userController.getPhotoURL(),
                    size: 160
                )
                .clipShape(Circle())
                .shadow(radius: 5)

                Text(userController.currentUser?.displayName ?? "Unknown User")
                    .font(.title)
                    .fontWeight(.semibold)
                    .tint(.blue)

                Text(userController.currentUser?.email ?? "No email")
                    .foregroundColor(.secondary)
                    .font(.subheadline)
            }
            VStack(spacing: 16) {
                Button(action: {
                    showEdit = true
                }) {
                    Label("Edit Profile", systemImage: "pencil")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .cornerRadius(12)
                }
                .sheet(isPresented: $showEdit) {
                    EditProfileView()
                }

                Button(action: {
                    authController.signOut()
                }) {
                    Label("Log Out", systemImage: "rectangle.portrait.and.arrow.right")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .foregroundColor(.red)
                        .cornerRadius(12)
                }
            }
            .padding(.top, 32)

            Spacer()
        }
        .padding()
        .navigationTitle("Profile")
    }
}

#Preview {
    ProfileView().environment(AuthController()).environment(UserController())
}
