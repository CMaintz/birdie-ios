//
//  HomeView.swift
//  Birdie
//
//  Created by dmu mac 33 on 15/05/2025.
//

import SwiftUI

struct HomeView: View {
    @Environment(UserController.self) var userController
    @Environment(BirdSpotController.self) var spotController

    @State private var spotCount: Int?
    @State private var loading = true

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                UserImageView(
                    imageURL: userController.getPhotoURL(),
                    size: 160
                )
                .clipShape(Circle())
                .shadow(radius: 4)

                Text(
                    greeting()
                )
                .font(.title2)
                .fontWeight(.medium)

                if loading {
                    ProgressView()
                        .padding(.top)
                } else if let count = spotCount {
                    if count > 0 {
                        Text(
                            "You've logged **\(count)** bird sighting\(count == 1 ? "" : "s")!"
                        )
                        .font(.headline)
                        .padding(.top)
                    } else {
                        VStack(spacing: 12) {
                            Text("No sightings yet!")
                                .font(.headline)
                            Text(
                                "Get peeping! Add your first spot using the + button."
                            )
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        }
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .padding(.top)
                    }
                } else {
                    Text("Unable to load sightings.")
                        .foregroundColor(.red)
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Home")
            .onAppear {
                Task {
                    await fetchUserSpotCount()
                }
            }
        }
    }

    private func greeting() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        let userName = "\(userController.getDisplayName() ?? "birder")"
        switch hour {
        case 5..<12: return "Good morning, \(userName)!"
        case 12..<17: return "Good afternoon, \(userName)!"
        case 17..<22: return "Good evening, \(userName)!"
        default: return "Out birding late, \(userName)?"
        }
    }

    private func fetchUserSpotCount() async {
        guard let userID = userController.getUserID() else { return }
        loading = true
        spotCount = await spotController.spotCount(for: userID)
        loading = false
    }
}

#Preview {
    HomeView().environment(UserController()).environment(BirdSpotController())
}
