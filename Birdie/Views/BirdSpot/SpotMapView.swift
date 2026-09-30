//
//  SpotMapView.swift
//  Birdie
//
//  Created by dmu mac 33 on 12/05/2025.
//

import MapKit
import SwiftUI

struct SpotMapView: View {
    @Environment(BirdSpotController.self) var spotController
    @Environment(LocationController.self) var locationController
    @Environment(UserController.self) var userController

    @State private var position: MapCameraPosition = .camera(
        MapCamera(
            centerCoordinate: CLLocationCoordinate2D(latitude: 56.0, longitude: 10.0),
            distance: 30000
        )
    )
    @State private var showFilter = false
    @State private var selectedSpot: BirdSpot?
    @State private var hasCenteredOnUser = false

    var body: some View {
        ZStack(alignment: .top) {
            Map(position: $position, bounds: .init(minimumDistance: 500)) {
                ForEach(spotController.spots) { spot in
                    Annotation(spot.species.rawValue, coordinate: spot.location.coordinate) {
                        Button {
                            selectedSpot = spot
                        } label: {
                            Image(systemName: "binoculars")
                                .padding(8)
                                .background(Circle().fill(Color.blue))
                                .foregroundColor(.white)
                        }
                    }
                }
                UserAnnotation()
            }
            .mapControls {
                MapUserLocationButton()
                MapCompass()
            }

            if let locationError = locationController.locationError {
                Label(locationError, systemImage: "location.slash")
                    .padding()
                    .background(.thinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding()
            } else if !hasCenteredOnUser {
                ProgressView("Loading location...")
                    .padding()
                    .background(.thinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding()
            }
        }
        .navigationTitle("Sightings Map")
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
        .sheet(item: $selectedSpot) { spot in
            SpotInfoSection(spot: spot)
                .presentationDetents([.fraction(0.25)])
        }
        .sheet(isPresented: $showFilter) {
            FilterView(initialFilters: spotController.filters) { newFilters in
                spotController.filters = newFilters
                Task { await reload() }
            }
            .presentationDetents([.fraction(0.65)])
        }
        .task { await reload() }
        .onAppear {
            locationController.startUpdatingLocation()
            centerOnUser()
        }
        .onDisappear {
            locationController.stopUpdatingLocation()
        }
        .onChange(of: locationController.currentLocation) {
            centerOnUser()
        }
    }

    private func reload() async {
        await spotController.loadSpots(
            currentUserID: userController.userID,
            near: locationController.currentLocation
        )
    }

    private func centerOnUser() {
        guard let location = locationController.currentLocation else { return }
        position = .camera(MapCamera(centerCoordinate: location.coordinate, distance: 3000))
        hasCenteredOnUser = true
    }
}

#Preview {
    NavigationStack {
        SpotMapView()
    }
    .withDemoEnvironment()
}
