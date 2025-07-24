//
//  VisualizerView.swift
//  MIDIVisualizer
//
//


import SwiftUI

struct VisualizerView: View {
    @ObservedObject var viewModel: VisualizerViewModel
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background pattern
                if viewModel.showBackgroundGrid {
                    BackgroundGridView()
                }
                
                // Visualizations
                switch viewModel.visualizationStyle {
                case .circles:
                    CircleVisualizationView(notes: viewModel.activeNotes, geometry: geometry)
                case .bars:
                    BarVisualizationView(notes: viewModel.activeNotes, geometry: geometry)
                }
            }
        }
    }
}

struct CircleVisualizationView: View {
    let notes: [NoteVisualization]
    let geometry: GeometryProxy
    
    var body: some View {
        ForEach(notes) { note in
            let xPos = calculateXPosition(for: note.pitch, in: geometry)
            let yPos = calculateYPosition(for: note.pitch, in: geometry)
            
            ZStack {
                // Circle
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                note.color.opacity(note.opacity),
                                note.color.opacity(note.opacity * 0.3)
                            ]),
                            center: .center,
                            startRadius: 0,
                            endRadius: note.radius
                        )
                    )
                    .frame(width: note.radius * 2, height: note.radius * 2)
                
                // Note name text
                Text(getNoteName(for: note.pitch))
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .opacity(note.opacity)
            }
            .position(x: xPos, y: yPos)
            .animation(.easeOut(duration: 0.3), value: note.radius)
            .animation(.easeOut(duration: note.fadeOutDuration), value: note.opacity)
        }
    }
    
    private func calculateXPosition(for pitch: UInt8, in geometry: GeometryProxy) -> CGFloat {
        // Map notes horizontally based on pitch class (0-11)
        let pitchClass = CGFloat(pitch % 12)
        let spacing = geometry.size.width / 12.0
        return spacing * pitchClass + spacing / 2.0
    }
    
    private func calculateYPosition(for pitch: UInt8, in geometry: GeometryProxy) -> CGFloat {
        // Map full MIDI pitch range (0-127) to screen height
        // Higher pitch = higher on screen (lower y value)
        let normalizedPitch = CGFloat(pitch) / 127.0
        let invertedPosition = 1.0 - normalizedPitch
        
        // Add padding from edges
        let padding: CGFloat = 50
        return padding + (invertedPosition * (geometry.size.height - padding * 2))
    }
    
    private func getNoteName(for note: UInt8) -> String {
        let noteNames = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
        let noteIndex = Int(note % 12)
        let octave = Int(note / 12) - 1
        return "\(noteNames[noteIndex])\(octave)"
    }
}


struct BarVisualizationView: View {
    let notes: [NoteVisualization]
    let geometry: GeometryProxy
    
    // All notes in octave 4 (including sharps)
    let octave4Notes: [UInt8] = [60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71] // C4 to B4
    
    var body: some View {
        ZStack {
            // Background bars for all 12 notes in octave 4
            VStack {
                Spacer()
                HStack(alignment: .bottom, spacing: 2) {
                    ForEach(octave4Notes, id: \.self) { note in
                        VStack(spacing: 2) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.gray.opacity(0.1))
                                .frame(width: geometry.size.width / 13.5, height: 20)
                            
                            Text(getNoteName(for: UInt8(note)))
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(.leading, 10)
                .padding(.trailing, 20) // Extra padding on right for B4
                .padding(.bottom, 10)
            }
            
            // Active note bars positioned to align with the 12-note layout
            ForEach(notes) { note in
                if note.pitch >= 60 && note.pitch <= 71 { // Only show notes in our keyboard range
                    let xPos = calculateBarXPosition(for: note.pitch, in: geometry)
                    let yPos = calculateBarYPosition(for: note.pitch, in: geometry)
                    let barHeight = calculateBarHeight(for: note)
                    
                    VStack {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        note.color.opacity(note.opacity),
                                        note.color.opacity(note.opacity * 0.3)
                                    ]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: geometry.size.width / 13.5 - 2, height: barHeight)
                            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: barHeight)
                            .animation(.easeOut(duration: note.fadeOutDuration), value: note.opacity)
                    }
                    .position(x: xPos, y: yPos)
                }
            }
        }
    }
    
    private func calculateBarXPosition(for pitch: UInt8, in geometry: GeometryProxy) -> CGFloat {
        let leftPadding: CGFloat = 10
        // let rightPadding: CGFloat = 20 // Removed unused variable
        let barWidth = geometry.size.width / 13.5
        let spacing: CGFloat = 2
        
        // Position based on note index (0-11 for C4-B4)
        let noteIndex = pitch - 60 // 60 is C4
        let xPosition = leftPadding + (CGFloat(noteIndex) * (barWidth + spacing)) + barWidth / 2
        
        return xPosition
    }
    
    private func calculateBarYPosition(for pitch: UInt8, in geometry: GeometryProxy) -> CGFloat {
        // Map full MIDI pitch range to vertical position
        // Since all our notes are in octave 4 (60-71), we'll show subtle differences
        let normalizedPitch = CGFloat(pitch - 60) / 11.0 // 0-1 range for our octave
        let heightVariation = normalizedPitch * 50 // Up to 50 points variation
        
        let barHeight = calculateBarHeight(for: NoteVisualization(pitch: pitch, velocity: 80, radius: 40, color: .blue, fadeOutDuration: 2.0))
        let bottomPadding: CGFloat = 60
        
        // Higher notes appear higher (lower y value)
        return geometry.size.height - bottomPadding - barHeight / 2 - heightVariation
    }
    
    private func calculateBarHeight(for note: NoteVisualization) -> CGFloat {
        // Bar height based on velocity
        let minHeight: CGFloat = 40
        let maxHeight: CGFloat = 200
        let velocityMultiplier = CGFloat(note.velocity) / 127.0
        return minHeight + (maxHeight - minHeight) * velocityMultiplier
    }
    
    private func getNoteName(for note: UInt8) -> String {
        let noteNames = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
        let noteIndex = Int(note % 12)
        let octave = Int(note / 12) - 1
        return "\(noteNames[noteIndex])\(octave)"
    }
}

struct BackgroundGridView: View {
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let gridSize: CGFloat = 50
                
                // Vertical lines
                for i in stride(from: 0, through: geometry.size.width, by: gridSize) {
                    path.move(to: CGPoint(x: i, y: 0))
                    path.addLine(to: CGPoint(x: i, y: geometry.size.height))
                }
                
                // Horizontal lines
                for i in stride(from: 0, through: geometry.size.height, by: gridSize) {
                    path.move(to: CGPoint(x: 0, y: i))
                    path.addLine(to: CGPoint(x: geometry.size.width, y: i))
                }
            }
            .stroke(Color.white.opacity(0.05), lineWidth: 1)
        }
    }
}
