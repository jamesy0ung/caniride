//
//  BOMAPIDTOs.swift
//  caniride
//
//  Created by James Young on 19/12/2025.
//

import Foundation

struct LocationResponse: Codable {
    let data: [Location]
}

struct Location: Codable {
    let geohash: String
    let id: String
    let name: String
    let postcode: String?
    let state: String
}

struct ObservationsResponse: Codable {
    let data: ObservationData
}

struct ObservationData: Codable {
    let temp: Double?
    let humidity: Int?
    let wind: Wind?
}

struct Wind: Codable {
    let speedKilometre: Double?
    
    enum CodingKeys: String, CodingKey {
        case speedKilometre = "speed_kilometre"
    }
}

struct ForecastHourlyResponse: Codable {
    let data: [HourlyForecast]
}

struct HourlyForecast: Codable {
    let rain: Rain?
    let time: String
}

struct Rain: Codable {
    let chance: Int?
}
