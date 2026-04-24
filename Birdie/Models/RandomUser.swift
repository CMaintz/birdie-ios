//
//  RandomUser.swift
//  Birdie
//
//  Created by dmu mac 33 on 12/05/2025.
//

import Foundation

struct RandomUserResponse: Decodable {
    let results: [RandomUser]
}

struct RandomUser: Codable {
    let email: String
    let login: LoginInfo
    let name: NameInfo
    let picture: Picture
    
    struct LoginInfo: Codable {
        let password: String
        let uuid: String
    }
    
    struct NameInfo: Codable {
        let title: String
        let first: String
        let last: String
    }
    
    struct Picture: Codable {
        let large: URL
        let medium: URL
    }
    
    var fullName: String {
        "\(name.title) \(name.first) \(name.last)"
    }
}

