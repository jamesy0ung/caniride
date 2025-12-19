//
//  RideQualityCalculator.swift
//  caniride
//
//  Created by James Young on 19/12/2025.
//

import Foundation

struct RideQualityCalculator {
    
    struct Preferences {
        let maxWind: Double
        let maxRainChance: Int
        let minTemp: Double
        let optTemp: Double
        let maxTemp: Double
    }
    
    static func calculateScore(weather: WeatherData, prefs: Preferences) -> Int {
        var score = 100.0
        
        // Wind Scoring
        if let wind = weather.windSpeed {
            if wind >= prefs.maxWind {
                return 0 // Immediate fail if > maxWind
            }
            
            let windRatio = wind / prefs.maxWind
            // Apply quadratic penalty because it doesn't feel linear on the bike
            let windPenalty = pow(windRatio, 2) * 60.0
            score -= windPenalty
        }
        
        // Precipitation Scoring
        if let rain = weather.precipitationChance {
            if rain > prefs.maxRainChance {
                return 0 // Immediate fail if > maxRainChance
            }
            let rainPenalty = (Double(rain) / Double(prefs.maxRainChance)) * 30.0
            score -= rainPenalty
        }
        
        // Temperature Scoring
        if let temp = weather.temperature {
            if temp < prefs.minTemp || temp > prefs.maxTemp {
                return 0 // Immediate fail if outside of minTemp and maxTemp
            }
            
            let distFromOptimal = abs(temp - prefs.optTemp)
            let maxDist = temp > prefs.optTemp ? (prefs.maxTemp - prefs.optTemp) : (prefs.optTemp - prefs.minTemp)
            
            if maxDist > 0 {
                let tempPenalty = (distFromOptimal / maxDist) * 40.0
                score -= tempPenalty
            }
        }
        
        return Int(max(0, score))
    }
}
