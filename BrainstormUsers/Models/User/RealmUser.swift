//
//  RealmUser.swift
//  BrainstormUsers
//
//  Created by Hovak Davtyan on 24.04.21.
//

import Foundation
import RealmSwift

class RealmUser: Object {
    @objc dynamic var id: String!
    @objc dynamic var fullName: String!
    @objc dynamic var avatarURL: String!
    @objc dynamic var info: String!
    @objc dynamic var country: String!
    @objc dynamic var address: String!
    @objc dynamic var latitude: String!
    @objc dynamic var longitude: String!

    convenience init(user: User) {
        self.init()
        self.id = user.id
        self.fullName = user.fullName
        self.avatarURL = user.avatar.absoluteString
        self.info = user.info
        self.country = user.country
        self.address = user.address
        self.latitude = String(user.latitude)
        self.longitude = String(user.longitude)
    }
}
