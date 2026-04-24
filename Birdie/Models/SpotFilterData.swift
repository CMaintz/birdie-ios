//
//  SpotFilterData.swift
//  Birdie
//
//  Created by dmu mac 33 on 15/05/2025.
//

import Foundation

struct SpotFilterData {
    var selectedSpecies: Set<String> = []
    var maxDistance: Double = 50
    var showOnlyMine: Bool = false
    var isDistanceFilteringEnabled: Bool = false
}
