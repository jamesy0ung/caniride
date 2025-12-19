//
//  ScoreDisplayView.swift
//  caniride
//
//  Created by James Young on 19/12/2025.
//

import SwiftUI

struct ScoreDisplayView: View {
    let score: Int
    let weather: WeatherData?
    
    var body: some View {
        VStack(spacing: 20) {
            Text("\(score)")
                .font(.system(size: 120, weight: .heavy, design: .rounded))
                .contentTransition(.numericText())
            
            Text(score > 75 ? "Go now!" : (score > 40 ? "It's okay" : "It's shit"))
                .font(.headline)
                .tracking(4)
                .opacity(0.8)
            
            if let w = weather {
                HStack(spacing: 20) {
                    WeatherStat(icon: "wind", value: String(format: "%.0f km/h", w.windSpeed ?? 0))
                    WeatherStat(icon: "thermometer", value: String(format: "%.0f°", w.temperature ?? 0))
                    WeatherStat(icon: "drop.fill", value: "\(w.precipitationChance ?? 0)%")
                }
                .padding(.top, 40)
            }
        }
    }
}

struct WeatherStat: View {
    let icon: String
    let value: String
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
            Text(value)
        }
        .font(.subheadline)
        .foregroundStyle(.secondary)
    }
}
