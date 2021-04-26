//
//  UserProtocol.swift
//  BrainstormUsers
//
//  Created by Hovak Davtyan on 25.04.21.
//

import Foundation

struct User: Hashable {
    let id: String
    let avatar: URL
    let fullName: String
    let info: String
    let country: String
    let address: String
    let latitude, longitude: Double

    var searchFields: [String] { [fullName, info, country, address] }

    init(user: RemoteUser) {
        id = user.login.uuid
        avatar = user.picture.large
        fullName = "\(user.name.first) \(user.name.last)"
        info = "\(user.gender.rawValue.capitalized), \(user.phone)"
        country = user.location.country
        address = "\(user.location.street.number) \(user.location.street.name) \(user.location.city) \(user.location.state)"
        latitude = user.location.coordinates.latitude
        longitude = user.location.coordinates.longitude
    }

    init?(user: RealmUser) {
        guard
            let avatarURL = URL(string: user.avatarURL),
            let latitude = Double(user.latitude),
            let longitude = Double(user.longitude)
        else { return nil }

        id = user.id
        avatar = avatarURL
        fullName = user.fullName
        info = user.info
        country = user.country
        address = user.address
        self.latitude = latitude
        self.longitude = longitude
    }
}
