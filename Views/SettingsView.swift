//
//  SettingsView.swift
//  MIDIVisualizer
//
//


import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: VisualizerViewModel
    @ObservedObject var audioEngine: AudioEngine
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        #if os(iOS)
        NavigationView {
            settingsForm
                .navigationTitle("Settings")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            dismiss()
                        }
                    }
                }
        }
        #else
        VStack(spacing: 0) {
            // macOS custom header
            HStack {
                Text("Settings")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding()
            .background(Color(white: 0.1))
            
            Divider()
            
            settingsForm
                .padding()
        }
        .frame(width: 400, height: 500)
        .background(Color.black.opacity(0.9))
        #endif
    }
    
    var settingsForm: some View {
        Form {
            Section(header: Text("Visualization Style")) {
                Picker("Style", selection: $viewModel.visualizationStyle) {
                    ForEach(VisualizationStyle.allCases, id: \.self) { style in
                        Text(style.rawValue).tag(style)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            
            Section(header: Text("Color Scheme")) {
                Picker("Colors", selection: $viewModel.colorScheme) {
                    ForEach(ColorScheme.allCases, id: \.self) { scheme in
                        HStack {
                            ColorPreview(scheme: scheme)
                            Text(scheme.rawValue)
                        }
                        .tag(scheme)
                    }
                }
                #if os(macOS)
                .pickerStyle(RadioGroupPickerStyle())
                #endif
            }
            
            Section(header: Text("Animation")) {
                VStack(alignment: .leading) {
                    Text("Animation Speed: \(String(format: "%.1fx", viewModel.animationSpeed))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Slider(value: $viewModel.animationSpeed, in: 0.5...2.0, step: 0.1)
                }
                
                Toggle("Show Background Grid", isOn: $viewModel.showBackgroundGrid)
                    #if os(macOS)
                    .toggleStyle(CheckboxToggleStyle())
                    #endif
            }
            
            Section(header: Text("Audio")) {
                Toggle("Sound Enabled", isOn: $audioEngine.isSoundEnabled)
                    #if os(macOS)
                    .toggleStyle(CheckboxToggleStyle())
                    #endif
            }
            
            Section(header: Text("About")) {
                HStack {
                    Text("Version")
                    Spacer()
                    Text("1.0.0")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Developer")
                    Spacer()
                    Text("ChangSu Nam")
                        .foregroundColor(.secondary)
                }
                
            }
        }
        #if os(macOS)
        .formStyle(.grouped)
        #endif
    }
}

struct ColorPreview: View {
    let scheme: ColorScheme
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<3) { i in
                Circle()
                    .fill(getColor(index: i))
                    .frame(width: 16, height: 16)
            }
        }
    }
    
    private func getColor(index: Int) -> Color {
        switch scheme {
        case .rainbow:
            let hue = Double(index) / 3.0
            return Color(hue: hue, saturation: 0.8, brightness: 0.9)
        case .fire:
            let intensity = Double(index) / 2.0
            return Color(red: 1.0, green: 0.3 + 0.4 * intensity, blue: 0.1)
        case .ocean:
            let intensity = Double(index) / 2.0
            return Color(red: 0.1, green: 0.5 + 0.3 * intensity, blue: 0.7 + 0.3 * intensity)
        }
    }
}

#Preview {
    SettingsView(viewModel: VisualizerViewModel(), audioEngine: AudioEngine())
}
