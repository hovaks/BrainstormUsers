//
//  UsersService.swift
//  BrainstormUsers
//
//  Created by Hovak Davtyan on 23.04.21.
//

import Alamofire
import Foundation
import RealmSwift

// MARK: - AlertableError

protocol AlertableError: Error {
    var title: String? { get }
    var message: String? { get }
}

// MARK: - UsersService

final class UsersService {
    // MARK: - Error

    enum ServiceError: AlertableError {
        case networkError(title: String? = "Network Error", message: String? = nil)
        case realmError(title: String? = "Realm Error", message: String? = nil)

        var title: String? {
            switch self {
            case .networkError(let title, _), .realmError(let title, _): return title
            }
        }

        var message: String? {
            switch self {
            case .networkError(_, let message), .realmError(_, let message): return message
            }
        }
    }

    // MARK: - Singleton

    static let shared: UsersService = .init()
    private init() {}

    // MARK: - REST

    private let baseURL = "https://randomuser.me/api"
    private let headers: HTTPHeaders = [
        "Accept": "application/json",
        "Content-Type": "application/json"
    ]

    // MARK: CRUD

    func getRemoteUsers(with parameters: UsersRequest, completion: @escaping (Result<[User], ServiceError>) -> ()) {
        guard let url = URL(string: baseURL) else { return }
        let encoder = URLEncodedFormParameterEncoder(encoder: URLEncodedFormEncoder(keyEncoding: .convertToSnakeCase))
        AF.request(
            url,
            parameters: parameters,
            encoder: encoder,
            headers: headers
        )
        .validate()
        .responseDecodable(
            of: UsersResponse.self,
            decoder: JSONDecoder.default
        ) { response in
            switch response.result {
            case .success(let value):
                completion(.success(value.results.map { .init(user: $0) }))
            case .failure(let error):
                completion(.failure(ServiceError.networkError(message: error.errorDescription)))
            }
        }
        .cURLDescription { description in
            print(description)
        }
    }

    // MARK: - Realm

    private lazy var realm: Realm = { try! Realm() }()

    // MARK: CRUD

    func getSavedUsers() -> [User] {
        let realmUsers = Array(realm.objects(RealmUser.self))
        return realmUsers.compactMap { User(user: $0) }
    }

    func save(user: User) throws {
        let realmUser = RealmUser(user: user)
        do {
            try realm.write { realm.add(realmUser) }
        } catch {
            throw ServiceError.realmError(message: error.localizedDescription)
        }
    }

    func delete(user: User) throws {
        let realmUser = realm.objects(RealmUser.self).filter("id = %@", user.id)
        do {
            try realm.write { realm.delete(realmUser) }
        } catch {
            throw ServiceError.realmError(message: error.localizedDescription)
        }
    }
}
