//
//  RemoteLocation.swift
//  BrainstormUsers
//
//  Created by Hovak Davtyan on 26.04.21.
//

import Foundation

struct RemoteLocation: Decodable, Hashable {
    // MARK: Street

    struct Street: Decodable, Hashable {
        let number: Int
        let name: String
    }

    // MARK: Coordinates

    struct Coordinates: Decodable, Hashable {
        let latitude, longitude: Double

        enum CodingKeys: String, CodingKey {
            case latitude, longitude
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            guard
                let latitude = Double(try container.decode(String.self, forKey: .latitude)),
                let longitude = Double(try container.decode(String.self, forKey: .longitude))
            else { fatalError() }

            self.latitude = latitude
            self.longitude = longitude
        }
    }

    // MARK: Location

    let street: Street
    let city, state, country, postcode: String
    let coordinates: Coordinates

    enum CodingKeys: String, CodingKey {
        case street
        case city, state, country, postcode
        case coordinates
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        street = try container.decode(Street.self, forKey: .street)
        city = try container.decode(String.self, forKey: .city)
        state = try container.decode(String.self, forKey: .state)
        country = try container.decode(String.self, forKey: .country)

        if let integerPostcode = try? container.decode(Int.self, forKey: .postcode) {
            postcode = String(integerPostcode)
        } else {
            postcode = try container.decode(String.self, forKey: .postcode)
        }

        coordinates = try container.decode(Coordinates.self, forKey: .coordinates)
    }
}
