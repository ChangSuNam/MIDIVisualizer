//
//  VisualizerViewModel.swift
//  MIDIVisualizer
//
//


import SwiftUI
import Combine

enum VisualizationStyle: String, CaseIterable {
    case circles = "Circles"
    case bars = "Bars"
}

enum ColorScheme: String, CaseIterable {
    case rainbow = "Rainbow"
    case fire = "Fire"
    case ocean = "Ocean"
}

struct NoteVisualization: Identifiable {
    let id = UUID()
    let pitch: UInt8
    let velocity: UInt8
    var radius: CGFloat
    var color: Color
    var opacity: Double = 1.0
    let fadeOutDuration: Double
    let timestamp: Date = Date()
}

class VisualizerViewModel: ObservableObject {
    @Published var activeNotes: [NoteVisualization] = []
    @Published var visualizationStyle: VisualizationStyle = .circles
    @Published var colorScheme: ColorScheme = .rainbow
    @Published var animationSpeed: Double = 1.0
    @Published var showBackgroundGrid: Bool = true
    
    private var noteTimers: [UInt8: Timer] = [:]
    
    // Calculate radius based on velocity
    private func calculateRadius(for velocity: UInt8) -> CGFloat {
        let minRadius: CGFloat = 10
        let maxRadius: CGFloat = 50
        let normalizedVelocity = CGFloat(velocity) / 127.0
        return minRadius + (maxRadius - minRadius) * normalizedVelocity
    }
    
    // Get color based on current color scheme and note
    private func getColor(for note: UInt8, velocity: UInt8) -> Color {
        switch colorScheme {
        case .rainbow:
            let hue = Double(note % 12) / 12.0
            return Color(hue: hue, saturation: 0.8, brightness: 0.9)
            
        case .fire:
            let intensity = Double(velocity) / 127.0
            return Color(red: 1.0, green: 0.3 + 0.4 * intensity, blue: 0.1)
            
        case .ocean:
            let intensity = Double(velocity) / 127.0
            return Color(red: 0.1, green: 0.5 + 0.3 * intensity, blue: 0.7 + 0.3 * intensity)
        }
    }
}

// MARK: - MIDIHandlerDelegate
extension VisualizerViewModel: MIDIHandlerDelegate {
    func midiNoteOn(note: UInt8, velocity: UInt8) {
        // Cancel any existing fade-out timer for this note
        noteTimers[note]?.invalidate()
        
        // Remove any existing visualization for this note
        activeNotes.removeAll { $0.pitch == note }
        
        // Create new visualization
        let visualization = NoteVisualization(
            pitch: note,
            velocity: velocity,
            radius: calculateRadius(for: velocity),
            color: getColor(for: note, velocity: velocity),
            fadeOutDuration: 2.0 / animationSpeed
        )
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            activeNotes.append(visualization)
        }
    }
    
    func midiNoteOff(note: UInt8) {
        // Find the visualization for this note
        guard let index = activeNotes.firstIndex(where: { $0.pitch == note }) else { return }
        
        // Start fade-out animation
        withAnimation(.easeOut(duration: activeNotes[index].fadeOutDuration)) {
            activeNotes[index].opacity = 0.0
        }
        
        // Remove after fade-out completes
        let timer = Timer.scheduledTimer(withTimeInterval: activeNotes[index].fadeOutDuration, repeats: false) { _ in
            self.activeNotes.removeAll { $0.pitch == note }
            self.noteTimers[note] = nil
        }
        
        noteTimers[note] = timer
    }
}
