//
//  BirdSpot.swift
//  Birdie
//
//  Created by dmu mac 33 on 12/05/2025.
//

import Foundation

struct BirdSpot: Identifiable, Codable, Equatable {
    /// Firestore document ID. `nil` until the spot has been stored.
    var id: String?
    var species: BirdSpecies
    var date: Date
    var location: Location
    var note: String?
    var userID: String
}
