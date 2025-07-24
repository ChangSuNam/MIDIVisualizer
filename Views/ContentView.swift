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
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [Color.black, Color(white: 0.1)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            if isCompact {
                compactLayout
            } else {
                regularLayout
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
        #if os(macOS)
        .frame(minWidth: 800, minHeight: 600)
        #endif
    }
    
    var isCompact: Bool {
        #if os(iOS)
        return horizontalSizeClass == .compact || verticalSizeClass == .compact
        #else
        return false
        #endif
    }
    
    var compactLayout: some View {
        VStack(spacing: 0) {
            // Header
            HeaderView(showSettings: $showSettings)
                .padding(.top, safeAreaTop)
            
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
                .padding(.bottom, safeAreaBottom)
        }
    }
    
    var regularLayout: some View {
        HStack(spacing: 0) {
            // Left side - Keyboard
            VStack {
                HeaderView(showSettings: $showSettings)
                    .padding()
                
                Spacer()
                
                VirtualKeyboardView(midiHandler: midiHandler, audioEngine: audioEngine)
                    .frame(height: 200)
                    .padding()
            }
            .frame(width: 300)
            .background(Color.black.opacity(0.2))
            
            // Right side - Visualizer
            VisualizerView(viewModel: visualizerViewModel)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black.opacity(0.3))
                .padding()
        }
    }
    
    var safeAreaTop: CGFloat {
        #if os(iOS)
        return 50
        #else
        return 20
        #endif
    }
    
    var safeAreaBottom: CGFloat {
        #if os(iOS)
        return 30
        #else
        return 20
        #endif
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
            #if os(macOS)
            .buttonStyle(PlainButtonStyle())
            #endif
        }
        .padding(.horizontal)
    }
}
