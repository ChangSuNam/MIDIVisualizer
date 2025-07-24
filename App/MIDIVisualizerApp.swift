//
//  MIDIVisualizerApp.swift
//  MIDIVisualizer
//
//


import SwiftUI

@main
struct MIDIVisualizerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                #if os(iOS)
                .preferredColorScheme(.dark)
                #endif
        }
        #if os(macOS)
        .windowStyle(.automatic)
        .commands {
            // Add menu bar items for macOS
            CommandGroup(replacing: .appInfo) {
                Button("About MIDI Visualizer") {
                    // Show about window
                }
            }
        }
        #endif
    }
}
