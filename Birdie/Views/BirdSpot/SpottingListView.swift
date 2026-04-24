//
//  SpottingListView.swift
//  Birdie
//
//  Created by dmu mac 33 on 13/05/2025.
//

import AlertToast
import SwiftUI

struct SpottingListView: View {
    @Environment(BirdSpotController.self) var spotController
    @Environment(AuthController.self) var authController
    @Environment(LocationController.self) var locationController
    @Environment(UserController.self) var userController
    @EnvironmentObject var toastManager: ToastManager

    @State private var showFilter: Bool = false
    @State private var selectedSpecies: BirdSpecies? = nil
    @State private var selectedSpot: BirdSpot? = nil
    @State private var showDeletionAlert: Bool = false

    var body: some View {
        NavigationStack {
            List(spotController.spots) { spot in
                NavigationLink(
                    destination: SpottingDetailView(spot: spot)
                ) {
                    SpotRow(
                        spot: spot,
                        userLocation: locationController.currentLocation
                    )
                }
                .swipeActions {
                    Button {
                        selectedSpot = spot
                        showDeletionAlert = true
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                    .tint(.red)
                }
            }
            .navigationTitle("Sightings")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showFilter.toggle()
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                            .resizable()
                            .frame(width: 32, height: 20)
                    }
                }
            }
            .overlay {
                if spotController.spots.isEmpty {
                    EmptyStateView()
                }
            }
            .alert(isPresented: $showDeletionAlert) {
                Alert(
                    title: Text("Warning!"),
                    message: Text(
                        "Are you sure you want to delete this sighting? This action cannot be undone!"
                    ),
                    primaryButton: .destructive(
                        Text("Delete"),
                        action: {
                            handleDelete()
                        }
                    ),
                    secondaryButton: .cancel()
                )
            }
            .sheet(isPresented: $showFilter) {
                FilterView(
                    initialFilters: spotController.filters,
                    onApply: { newFilters in
                        Task {
                            spotController.filters = newFilters
                            await spotController.updateSpots(
                                currentLocation: locationController
                                    .currentLocation
                            )
                            showFilter = false
                        }
                    }
                )
                .presentationDetents([.fraction(0.65)])
            }
            .toast(isPresenting: $toastManager.show) {
                toastManager.alertToast
            }
        .onAppear {
            locationController.startUpdatingLocation()
        }
        .onDisappear {
            locationController.stopUpdatingLocation()
        }
    }

    private func handleDelete() {
        guard let spot = selectedSpot else { return }
        let currentUserID = userController.getUserID()

        if spot.userID != currentUserID {
            toastManager.showToast(
                AlertToast(
                    type: .error(.red),
                    title: "Not allowed",
                    subTitle: "You can only delete your own sightings."
                )
            )
            return
        }

        Task {
            guard let currentUserID else { return }
            await spotController.delete(spot, currentUserID)
            await spotController.updateSpots(
                currentLocation: locationController.currentLocation
            )

            toastManager.showToast(
                AlertToast(
                    type: .complete(.green),
                    title: "Sighting deleted!"
                )
            )

        }
    }
}
