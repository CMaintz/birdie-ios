//
//  SecretKeys.swift
//  Birdie
//
//  Created by dmu mac 33 on 16/05/2025.
//

import Foundation

enum SecretKeys {
    
    static var openCageKey: String {
        guard
            let url = Bundle.main.url(
                forResource: "Secrets",
                withExtension: "plist"
            ),
            let data = try? Data(contentsOf: url),
            let plist = try? PropertyListSerialization.propertyList(
                from: data,
                format: nil
            ) as? [String: Any],
            let key = plist["openCageKey"] as? String
        else {
            fatalError(
                "Missing or invalid OpenCage API key in Secrets.plist"
            )
        }
        return key
    }
}
