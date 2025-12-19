//
//  ContentView.swift
//  caniride
//
//  Created by James Young on 19/12/2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = WeatherViewModel()
    @State private var showSettings = false
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                
                if viewModel.isLoading {
                    ProgressView()
                        .controlSize(.large)
                } else if let err = viewModel.errorMessage {
                    VStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundStyle(.orange)
                        Text(err)
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                } else if let score = viewModel.score {
                    VStack {
                        ScoreDisplayView(score: score, weather: viewModel.weatherData)
                    }
                    .foregroundStyle(scoreColor)
                    .font(.system(.largeTitle, design: .rounded).weight(.semibold))
                } else {
                    VStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .font(.largeTitle)
                            .foregroundStyle(.secondary)
                        Text("Enter a postcode in settings")
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Spacer()
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showSettings = true }) {
                        Image(systemName: "gearshape") // Hollow icon
                            .foregroundStyle(.primary)
                    }
                }
            }
            .sheet(isPresented: $showSettings, onDismiss: {
                viewModel.refreshWeather()
            }) {
                SettingsView(viewModel: viewModel)
            }
            .onAppear {
                if !viewModel.postcode.isEmpty {
                    viewModel.refreshWeather()
                }
            }
        }
    }
    
    var scoreColor: Color {
        guard let score = viewModel.score else { return .primary }
        // Gradient from red, 0 to green, 100
        let hue = (Double(score) / 100.0) * 0.33
        // High saturation/brightness to be visible in Light AND Dark mode
        return Color(hue: hue, saturation: 0.9, brightness: 0.9)
    }
}
