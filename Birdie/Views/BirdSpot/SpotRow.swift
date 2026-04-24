//
//  SpotRow.swift
//  Birdie
//
//  Created by dmu mac 33 on 14/05/2025.
//

import CoreLocation
import SwiftUI

struct SpotRow: View {
    let spot: BirdSpot
    let userLocation: Location?

    var body: some View {
        VStack(alignment: .leading) {
            Text(spot.species.rawValue.capitalized)
                .font(.headline)
            Text(
                "Date: \(DateFormatter.localizedString(from: spot.date, dateStyle: .medium, timeStyle: .none))"
            )
            .font(.subheadline)

            if let userLocation = userLocation {
                let distanceString = userLocation.formattedDistance(
                    to: spot.location
                )
                Text("\(distanceString) from you")
                    .font(.caption)
                    .foregroundStyle(.gray)
            }
        }
    }

}
