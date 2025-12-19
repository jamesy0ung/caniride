//
//  SettingsView.swift
//  caniride
//
//  Created by James Young on 19/12/2025.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: WeatherViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Location") {
                    TextField("Postcode (e.g. 2000)", text: $viewModel.postcode)
                        .keyboardType(.numberPad)
                }
                
                Section("Wind Preferences") {
                    VStack(alignment: .leading) {
                        Text("Max Wind: \(Int(viewModel.prefMaxWind)) km/h")
                        Slider(value: $viewModel.prefMaxWind, in: 5...60, step: 1) {
                            Text("Max Wind")
                        } minimumValueLabel: {
                            Text(Image(systemName: "wind"))
                        } maximumValueLabel: {
                            Text("60")
                        }
                    }
                    Text("Wind drag penalty is calculated exponentially.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Section("Temperature Preferences") {
                    VStack(alignment: .leading) {
                        Text("Minimum: \(Int(viewModel.prefMinTemp))°")
                        Slider(value: $viewModel.prefMinTemp, in: -5...20, step: 1)
                    }
                    VStack(alignment: .leading) {
                        Text("Optimal: \(Int(viewModel.prefOptTemp))°")
                        Slider(value: $viewModel.prefOptTemp, in: 10...30, step: 1)
                    }
                    VStack(alignment: .leading) {
                        Text("Maximum: \(Int(viewModel.prefMaxTemp))°")
                        Slider(value: $viewModel.prefMaxTemp, in: 20...45, step: 1)
                    }
                }
                
                Section("Precipitation") {
                    VStack(alignment: .leading) {
                        Text("Max Chance: \(viewModel.prefMaxRain)%")
                        Slider(value: Binding(get: {
                            Double(viewModel.prefMaxRain)
                        }, set: {
                            viewModel.prefMaxRain = Int($0)
                        }), in: 0...100, step: 5)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
