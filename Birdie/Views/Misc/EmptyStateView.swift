//
//  EmptyStateView.swift
//  Birdie
//
//  Created by dmu mac 33 on 14/05/2025.
//

import SwiftUI

struct EmptyStateView: View {
    var body: some View {
        ContentUnavailableView(
            label: { Text("😕 No sightings found! 😕") },
            description: {
                Text("Why don't you add some?")
            }
        )
    }
}
