//
//  BirdieUser.swift
//  Birdie
//
//  Created by dmu mac 33 on 15/05/2025.
//

import Foundation

struct BirdieUser: Identifiable, Equatable {
    let id: String
    let email: String
    let displayName: String
    let imageURL: String?

    var profileImageURL: URL? {
        guard let imageURL, !imageURL.isEmpty else { return nil }
        return URL(string: imageURL)
    }
}
