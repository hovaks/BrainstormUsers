//
//  User.swift
//  BrainstormUsers
//
//  Created by Hovak Davtyan on 23.04.21.
//

import Foundation

// MARK: - RemoteUser

struct RemoteUser: Decodable, Hashable {
    // MARK: - Nested

    struct Login: Decodable, Hashable {
        let uuid: String
    }

    struct Name: Decodable, Hashable {
        let first: String
        let last: String
    }

    enum Gender: String, Decodable {
        case male
        case female
    }

    struct Picture: Decodable, Hashable {
        let thumbnail: URL
        let medium: URL
        let large: URL
    }

    // MARK: - RemoteUser

    let login: Login
    let name: Name
    let gender: Gender
    let phone: String
    let location: RemoteLocation
    let picture: Picture
}
