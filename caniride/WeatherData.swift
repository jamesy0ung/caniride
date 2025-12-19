//
//  WeatherData.swift
//  caniride
//
//  Created by James Young on 19/12/2025.
//

import Foundation

struct WeatherData: Codable {
    let temperature: Double?
    let windSpeed: Double?
    let humidity: Int?
    let precipitationChance: Int?
    let timestamp: Date
    
    var isValid: Bool {
        temperature != nil && windSpeed != nil && humidity != nil && precipitationChance != nil
    }
}
