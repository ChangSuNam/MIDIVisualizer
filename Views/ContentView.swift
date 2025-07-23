//
//  ContentView.swift
//  MIDIVisualizer
//
//


import SwiftUI

struct ContentView: View {
    @StateObject private var midiHandler = MIDIHandler()
    @StateObject private var visualizerViewModel = VisualizerViewModel()
    @StateObject private var audioEngine = AudioEngine()
    @State private var showSettings = false
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [Color.black, Color(white: 0.1)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HeaderView(showSettings: $showSettings)
                    .padding(.top, 50)
                
                // Visualizer Area
                VisualizerView(viewModel: visualizerViewModel)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.3))
                    .cornerRadius(20)
                    .padding(.horizontal)
                
                // Virtual Keyboard
                VirtualKeyboardView(midiHandler: midiHandler, audioEngine: audioEngine)
                    .frame(height: 180)
                    .padding(.horizontal)
                    .padding(.bottom, 30)
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(viewModel: visualizerViewModel, audioEngine: audioEngine)
        }
        .onAppear {
            midiHandler.delegate = visualizerViewModel
            midiHandler.audioEngine = audioEngine
            midiHandler.setupMIDI()
        }
    }
}

struct HeaderView: View {
    @Binding var showSettings: Bool
    
    var body: some View {
        HStack {
            Text("MIDI Visualizer")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Spacer()
            
            Button(action: { showSettings = true }) {
                Image(systemName: "gearshape.fill")
                    .font(.title2)
                    .foregroundColor(.white)
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    ContentView()
}
