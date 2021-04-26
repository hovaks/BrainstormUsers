//
//  UsersRequest.swift
//  BrainstormUsers
//
//  Created by Hovak Davtyan on 23.04.21.
//

struct UsersRequest: Encodable {
    let seed = "Brainstorm"
    let results: Int
    let page: Int
}
