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
    @Environment(AuthController.self) var authController
    @Environment(LocationController.self) var locationController

    @State private var position: MapCameraPosition = .camera(
        MapCamera(
            centerCoordinate: CLLocationCoordinate2D(
                latitude: 56.0,
                longitude: 10.0
            ),
            distance: 30000
        )
    )
    @State private var spots: [BirdSpot] = []
    @State private var showFilter = false
    @State private var selectedSpot: BirdSpot?
    @State private var isLoading = true

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Map(position: $position, bounds: .init(minimumDistance: 500)) {
                ForEach(spotController.spots, id: \.id) { spot in
                    Annotation(
                        spot.species.rawValue,
                        coordinate: spot.location.coordinate
                    ) {
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
            .onAppear {
                if locationController.currentLocation != nil {
                    updateMapPosition()
                } else {
                    Task {
                        try? await Task.sleep(nanoseconds: 1_000_000_000)
                        if locationController.currentLocation != nil {
                            updateMapPosition()
                        }
                    }
                }
            }

            .onChange(of: locationController.currentLocation) {
                updateMapPosition()
            }
            .navigationTitle("Sightings Map")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showFilter.toggle()
                    } label: {
                        Image(systemName: "slider.horizontal.3").resizable()
                            .frame(width: 32, height: 20)
                    }

                }
            }

            .sheet(item: $selectedSpot) { spot in
                SpotInfoSection(spot: spot)
                    .presentationDetents([.fraction(0.25)])
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
            if isLoading {
                ProgressView("Loading location...")
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding()
                    .background(.thinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }

        }
        .onAppear {
            locationController.startUpdatingLocation()
        }
        .onDisappear {
            locationController.stopUpdatingLocation()
        }
    }
    

    private func updateMapPosition() {
        guard let location = locationController.currentLocation else { return }
        position = .camera(
            MapCamera(centerCoordinate: location.coordinate, distance: 1000)
        )
        isLoading = false
    }
}

#Preview {
    SpotMapView()
        .environment(BirdSpotController())
        .environment(AuthController())
        .environment(LocationController())
}
