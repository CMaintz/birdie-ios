//
//  FilterView.swift
//  Birdie
//
//  Created by dmu mac 33 on 14/05/2025.
//

import SwiftUI

struct FilterView: View {
    @Environment(\.dismiss) private var dismiss

    let initialFilters: SpotFilterData
    var onApply: (SpotFilterData) -> Void

    @State private var localFilters: SpotFilterData

    init(
        initialFilters: SpotFilterData,
        onApply: @escaping (SpotFilterData) -> Void,
    ) {
        self.initialFilters = initialFilters
        self.onApply = onApply
        _localFilters = State(initialValue: initialFilters)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Distance Filter")) {
                    Toggle(
                        "Enable Distance Filter",
                        isOn: $localFilters.isDistanceFilteringEnabled
                    )

                    if localFilters.isDistanceFilteringEnabled {
                        Slider(value: $localFilters.maxDistance, in: 1...1000)
                        Text("Up to \(Int(localFilters.maxDistance)) km")
                    }
                }
                Section(header: Text("User Sightings")) {
                    Toggle(
                        "Show Only My Sightings",
                        isOn: $localFilters.showOnlyMine
                    )
                }
                Section(header: Text("Species")) {
                    SpeciesPickerView(
                        selectedSpecies: $localFilters.selectedSpecies
                    )
                    .padding(.top, 6)
                }
            }
            .navigationTitle("Filter Sightings")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        localFilters = initialFilters
                        dismiss()
                    }
                }

                ToolbarItem(placement: .bottomBar) {
                    Button("Reset Filters") {
                        localFilters = SpotFilterData()
                    }
                    .buttonStyle(.bordered)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Apply") {
                        onApply(localFilters)
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    FilterView(initialFilters: SpotFilterData()) { _ in }
        .withDemoEnvironment()
}
