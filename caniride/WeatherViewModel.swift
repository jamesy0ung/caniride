//
//  WeatherViewModel.swift
//  caniride
//
//  Created by James Young on 19/12/2025.
//

import SwiftUI
import Combine

@MainActor
class WeatherViewModel: ObservableObject {
    @Published var score: Int? = nil
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    @Published var weatherData: WeatherData? = nil
    
    // User Preferences
    @AppStorage("userPostcode") var postcode: String = ""
    @AppStorage("prefMaxWind") var prefMaxWind: Double = 30.0
    @AppStorage("prefMaxRain") var prefMaxRain: Int = 20
    @AppStorage("prefMinTemp") var prefMinTemp: Double = 13.0
    @AppStorage("prefOptTemp") var prefOptTemp: Double = 20.0
    @AppStorage("prefMaxTemp") var prefMaxTemp: Double = 28.0
    
    func refreshWeather() {
        guard let postcodeInt = Int(postcode), postcode.count == 4 else {
            self.errorMessage = "Enter valid postcode"
            return
        }
        
        self.isLoading = true
        self.errorMessage = nil
        
        Task {
            do {
                let weather = try await BOMWeatherAPI.shared.getWeather(postcode: postcodeInt)
                self.weatherData = weather
                
                let prefs = RideQualityCalculator.Preferences(
                    maxWind: prefMaxWind,
                    maxRainChance: prefMaxRain,
                    minTemp: prefMinTemp,
                    optTemp: prefOptTemp,
                    maxTemp: prefMaxTemp
                )
                
                let calculatedScore = RideQualityCalculator.calculateScore(weather: weather, prefs: prefs)
                
                withAnimation {
                    self.score = calculatedScore
                    self.isLoading = false
                }
            } catch {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
}
