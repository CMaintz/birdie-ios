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
    @Environment(LocationController.self) var locationController
    @Environment(UserController.self) var userController
    @EnvironmentObject var toastManager: ToastManager

    @State private var showFilter = false
    @State private var spotPendingDeletion: BirdSpot?

    var body: some View {
        List(spotController.spots) { spot in
            NavigationLink(destination: SpottingDetailView(spot: spot)) {
                SpotRow(spot: spot, userLocation: locationController.currentLocation)
            }
            .swipeActions {
                if spotController.canDelete(spot, as: userController.userID) {
                    Button {
                        spotPendingDeletion = spot
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                    .tint(.red)
                }
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
                .accessibilityLabel("Filter sightings")
            }
        }
        .overlay {
            if spotController.spots.isEmpty && !spotController.isLoading {
                EmptyStateView()
            }
        }
        .alert(
            "Delete this sighting?",
            isPresented: Binding(
                get: { spotPendingDeletion != nil },
                set: { if !$0 { spotPendingDeletion = nil } }
            ),
            presenting: spotPendingDeletion
        ) { spot in
            Button("Delete", role: .destructive) {
                Task { await delete(spot) }
            }
            Button("Cancel", role: .cancel) {}
        } message: { _ in
            Text("This action cannot be undone.")
        }
        .sheet(isPresented: $showFilter) {
            FilterView(initialFilters: spotController.filters) { newFilters in
                spotController.filters = newFilters
                Task { await reload() }
            }
            .presentationDetents([.fraction(0.65)])
        }
        .task { await reload() }
        .refreshable { await reload() }
        .onAppear {
            locationController.startUpdatingLocation()
        }
        .onDisappear {
            locationController.stopUpdatingLocation()
        }
    }

    private func reload() async {
        await spotController.loadSpots(
            currentUserID: userController.userID,
            near: locationController.currentLocation
        )
    }

    private func delete(_ spot: BirdSpot) async {
        guard await spotController.delete(spot, as: userController.userID) else { return }
        toastManager.showToast(
            AlertToast(type: .complete(.green), title: "Sighting deleted!")
        )
    }
}

#Preview {
    NavigationStack {
        SpottingListView()
    }
    .withDemoEnvironment()
}
