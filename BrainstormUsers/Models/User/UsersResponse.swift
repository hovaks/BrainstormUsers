//
//  UsersResponse.swift
//  BrainstormUsers
//
//  Created by Hovak Davtyan on 23.04.21.
//

import Foundation

struct UsersResponse: Decodable {
    let results: [RemoteUser]
}
