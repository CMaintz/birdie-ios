//
//  BirdieUser.swift
//  Birdie
//
//  Created by dmu mac 33 on 15/05/2025.
//

import Foundation

struct BirdieUser: Identifiable {
    let id: String
    let email: String
    let displayName: String
    let imageURL: String?

    var profileImageURL: URL? {
        guard let unwrappedImageURL = imageURL, !unwrappedImageURL.isEmpty else { return nil }
        return URL(string: unwrappedImageURL)
    }

    
}
