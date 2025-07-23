//
//  VirtualKeyboardView.swift
//  MIDIVisualizer
//
//


import SwiftUI

struct VirtualKeyboardView: View {
    @ObservedObject var midiHandler: MIDIHandler
    @ObservedObject var audioEngine: AudioEngine
    @State private var pressedKeys: Set<UInt8> = []
    
    let whiteKeys: [UInt8] = [60, 62, 64, 65, 67, 69, 71] // C, D, E, F, G, A, B
    let blackKeys: [(note: UInt8, position: CGFloat)] = [
        (61, 0.5),   // C# - between C and D (positions 0 and 1)
        (63, 1.5),   // D# - between D and E (positions 1 and 2)
        (66, 3.5),   // F# - between F and G (positions 3 and 4)
        (68, 4.5),   // G# - between G and A (positions 4 and 5)
        (70, 5.5),   // A# - between A and B (positions 5 and 6)
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Demo button
            HStack {
                Button(action: {
                    midiHandler.playDemoSequence()
                }) {
                    HStack {
                        Image(systemName: "play.circle.fill")
                        Text("Play Demo")
                    }
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.blue)
                    .cornerRadius(25)
                }
                .padding(.bottom, 10)
            }
            
            // Keyboard
            GeometryReader { geometry in
                let whiteKeyWidth = (geometry.size.width - 12) / 7.0 // Account for spacing
                let blackKeyWidth = whiteKeyWidth * 0.6
                
                ZStack(alignment: .leading) {
                    // White keys
                    HStack(spacing: 2) {
                        ForEach(whiteKeys, id: \.self) { note in
                            WhiteKeyView(
                                note: note,
                                noteName: midiHandler.getNoteName(for: note),
                                isPressed: pressedKeys.contains(note),
                                onPress: { handleKeyPress(note) },
                                onRelease: { handleKeyRelease(note) }
                            )
                        }
                    }
                    
                    // Black keys with precise positioning
                    BlackKeyView(
                        note: 61,
                        noteName: midiHandler.getNoteName(for: 61),
                        isPressed: pressedKeys.contains(61),
                        position: whiteKeyWidth - blackKeyWidth/2,
                        onPress: { handleKeyPress(61) },
                        onRelease: { handleKeyRelease(61) }
                    )
                    
                    BlackKeyView(
                        note: 63,
                        noteName: midiHandler.getNoteName(for: 63),
                        isPressed: pressedKeys.contains(63),
                        position: (whiteKeyWidth + 2) * 2 - blackKeyWidth/2,
                        onPress: { handleKeyPress(63) },
                        onRelease: { handleKeyRelease(63) }
                    )
                    
                    BlackKeyView(
                        note: 66,
                        noteName: midiHandler.getNoteName(for: 66),
                        isPressed: pressedKeys.contains(66),
                        position: (whiteKeyWidth + 2) * 4 - blackKeyWidth/2,
                        onPress: { handleKeyPress(66) },
                        onRelease: { handleKeyRelease(66) }
                    )
                    
                    BlackKeyView(
                        note: 68,
                        noteName: midiHandler.getNoteName(for: 68),
                        isPressed: pressedKeys.contains(68),
                        position: (whiteKeyWidth + 2) * 5 - blackKeyWidth/2,
                        onPress: { handleKeyPress(68) },
                        onRelease: { handleKeyRelease(68) }
                    )
                    
                    BlackKeyView(
                        note: 70,
                        noteName: midiHandler.getNoteName(for: 70),
                        isPressed: pressedKeys.contains(70),
                        position: (whiteKeyWidth + 2) * 6 - blackKeyWidth/2,
                        onPress: { handleKeyPress(70) },
                        onRelease: { handleKeyRelease(70) }
                    )
                }
            }
        }
    }
    
    private func handleKeyPress(_ note: UInt8) {
        pressedKeys.insert(note)
        // Velocity based on random value for demo (in real app, could use touch force)
        let velocity = UInt8.random(in: 60...100)
        midiHandler.sendNoteOn(note: note, velocity: velocity)
        audioEngine.playNote(note, velocity: velocity)
    }
    
    private func handleKeyRelease(_ note: UInt8) {
        pressedKeys.remove(note)
        midiHandler.sendNoteOff(note: note)
        audioEngine.stopNote(note)
    }
}

struct WhiteKeyView: View {
    let note: UInt8
    let noteName: String
    let isPressed: Bool
    let onPress: () -> Void
    let onRelease: () -> Void
    
    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(isPressed ? Color.gray.opacity(0.8) : Color.white)
            .overlay(
                VStack {
                    Spacer()
                    Text(noteName)
                        .font(.caption)
                        .foregroundColor(.black)
                        .padding(.bottom, 10)
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray, lineWidth: 1)
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: isPressed)
            .onLongPressGesture(
                minimumDuration: 0,
                maximumDistance: .infinity,
                pressing: { pressing in
                    if pressing {
                        onPress()
                    } else {
                        onRelease()
                    }
                },
                perform: {}
            )
    }
}

struct BlackKeyView: View {
    let note: UInt8
    let noteName: String
    let isPressed: Bool
    let position: CGFloat
    let onPress: () -> Void
    let onRelease: () -> Void
    
    var body: some View {
        RoundedRectangle(cornerRadius: 6)
            .fill(isPressed ? Color.gray : Color.black)
            .frame(width: 35, height: 90)
            .overlay(
                VStack {
                    Spacer()
                    Text(noteName)
                        .font(.caption2)
                        .foregroundColor(.white)
                        .padding(.bottom, 8)
                }
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: isPressed)
            .offset(x: position)
            .zIndex(1) // Black keys on top
            .onLongPressGesture(
                minimumDuration: 0,
                maximumDistance: .infinity,
                pressing: { pressing in
                    if pressing {
                        onPress()
                    } else {
                        onRelease()
                    }
                },
                perform: {}
            )
    }
}
