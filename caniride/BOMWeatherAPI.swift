//
//  BOMWeatherAPI.swift
//  caniride
//
//  Created by James Young on 19/12/2025.
//

import Foundation

enum WeatherError: LocalizedError {
    case invalidURL
    case networkError
    case locationNotFound
    case decodingError
    
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL"
        case .networkError: return "Network request failed"
        case .locationNotFound: return "Location not found for postcode"
        case .decodingError: return "Failed to decode response"
        }
    }
}

class BOMWeatherAPI {
    static let shared = BOMWeatherAPI()
    
    private let baseURL = "https://api.weather.bom.gov.au/v1"
    private let cache = NSCache<NSString, CachedWeather>()
    private let cacheTTL: TimeInterval = 600 // 10 minutes
    
    private init() {
        cache.countLimit = 50
    }
    
    func getWeather(postcode: Int) async throws -> WeatherData {
        let cacheKey = "\(postcode)" as NSString
        
        if let cached = cache.object(forKey: cacheKey),
           Date().timeIntervalSince(cached.timestamp) < cacheTTL {
            return cached.weather
        }
        
        let weather = try await fetchWeather(postcode: postcode)
        
        if weather.isValid {
            cache.setObject(CachedWeather(weather: weather, timestamp: Date()), forKey: cacheKey)
        }
        
        return weather
    }
    
    private func fetchWeather(postcode: Int) async throws -> WeatherData {
        let locations = try await searchLocation(query: "\(postcode)")
        
        guard let location = locations.first else {
            throw WeatherError.locationNotFound
        }
        
        let geohash = String(location.geohash.prefix(6))
        
        async let observations = fetchObservations(geohash: geohash)
        async let hourlyForecast = fetchHourlyForecast(geohash: geohash)
        
        let (obs, forecast) = try await (observations, hourlyForecast)
        let precipChance = forecast.first?.rain?.chance
        
        return WeatherData(
            temperature: obs.temp,
            windSpeed: obs.wind?.speedKilometre,
            humidity: obs.humidity,
            precipitationChance: precipChance,
            timestamp: Date()
        )
    }
    
    private func searchLocation(query: String) async throws -> [Location] {
        try await performRequest(urlString: "\(baseURL)/locations?search=\(query)") {
            try JSONDecoder().decode(LocationResponse.self, from: $0).data
        }
    }
    
    private func fetchObservations(geohash: String) async throws -> ObservationData {
        try await performRequest(urlString: "\(baseURL)/locations/\(geohash)/observations") {
            try JSONDecoder().decode(ObservationsResponse.self, from: $0).data
        }
    }
    
    private func fetchHourlyForecast(geohash: String) async throws -> [HourlyForecast] {
        try await performRequest(urlString: "\(baseURL)/locations/\(geohash)/forecasts/hourly") {
            try JSONDecoder().decode(ForecastHourlyResponse.self, from: $0).data
        }
    }
    
    private func performRequest<T>(urlString: String, decoder: (Data) throws -> T) async throws -> T {
        guard let url = URL(string: urlString) else { throw WeatherError.invalidURL }
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw WeatherError.networkError
        }
        return try decoder(data)
    }
    
    func clearCache() {
        cache.removeAllObjects()
    }
}

class CachedWeather {
    let weather: WeatherData
    let timestamp: Date
    init(weather: WeatherData, timestamp: Date) {
        self.weather = weather
        self.timestamp = timestamp
    }
}
