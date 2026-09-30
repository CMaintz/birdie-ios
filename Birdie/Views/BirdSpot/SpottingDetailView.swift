//
//  SpottingDetailView.swift
//  Birdie
//
//  Created by dmu mac 33 on 14/05/2025.
//

import MapKit
import SwiftUI

struct SpottingDetailView: View {
    let spot: BirdSpot

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("Bird Sighting Details")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 20)

                SpottingMapSection(for: spot)
                SpotInfoSection(spot: spot)
            }
            .padding()
        }
        .background(
            LinearGradient(
                colors: [.blue.opacity(0.1), .green.opacity(0.1)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .ignoresSafeArea(edges: .bottom)
    }
}

struct SpottingMapSection: View {
    let spot: BirdSpot
    @State private var position: MapCameraPosition

    init(for spot: BirdSpot) {
        self.spot = spot
        _position = State(
            initialValue: .region(
                MKCoordinateRegion(
                    center: spot.location.coordinate,
                    span: MKCoordinateSpan(
                        latitudeDelta: 0.01,
                        longitudeDelta: 0.01
                    )
                )
            )
        )
    }

    var body: some View {
        Map(position: $position) {
            Marker(
                spot.species.rawValue,
                image: "binoculars",
                coordinate: spot.location.coordinate
            )

            UserAnnotation()
        }
        .mapControls {
            MapUserLocationButton()
            MapCompass()
        }
        .frame(height: 300)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .gray.opacity(0.3), radius: 8, x: 0, y: 4)
    }
}

struct SpotInfoSection: View {
    @Environment(LocationController.self) private var locationController
    
    let spot: BirdSpot

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "bird")
                    .foregroundColor(.green)
                Text("Species:")
                    .font(.headline)
                Text(spot.species.rawValue.capitalized)
            }

            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(.orange)
                Text("Spotted:")
                    .font(.headline)
                Text(
                    DateFormatter.localizedString(
                        from: spot.date,
                        dateStyle: .medium,
                        timeStyle: .short
                    )
                )
            }
            
            if let currentLocation = locationController.currentLocation {
                HStack {
                    Image(systemName: "mappin.and.ellipse")
                        .foregroundColor(.red)
                    Text("Distance:")
                        .font(.headline)
                    Text("\(currentLocation.formattedDistance(to: spot.location)) from you")
                }
            }

            if let note = spot.note, !note.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Notes:")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text("“\(note)”")
                        .italic()
                        .padding(.top, 2)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
        .onAppear {
            locationController.startUpdatingLocation()
        }
        .onDisappear {
            locationController.stopUpdatingLocation()
        }
    }
}

#Preview {
    SpottingDetailView(
        spot: BirdSpot(
            species: BirdSpecies.toucan,
            date: Date(),
            location: Location(latitude: 54, longitude: 16),
            note:
                "A toucan was spotted rolling around on the moon, mysterious and mildly annoyed, wearing a bowtie.",
            userID: "1awe2"
        )
    )
    .withDemoEnvironment()
}
