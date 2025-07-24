//
//  AudioEngine.swift
//  MIDIVisualizer
//
//


import AVFoundation
import Foundation

class AudioEngine: ObservableObject {
    @Published var isSoundEnabled: Bool = true
    private var audioEngine: AVAudioEngine
    private var samplerNode: AVAudioUnitSampler
    
    init() {
        audioEngine = AVAudioEngine()
        samplerNode = AVAudioUnitSampler()
        setupAudio()
    }
    
    private func setupAudio() {
        #if os(iOS)
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default)
            try audioSession.setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
        #endif
        
        // Attach and connect nodes - works on both platforms
        audioEngine.attach(samplerNode)
        audioEngine.connect(samplerNode, to: audioEngine.mainMixerNode, format: nil)
        
        // Start the engine
        do {
            try audioEngine.start()
            loadDefaultSound()
        } catch {
            print("Failed to start audio engine: \(error)")
        }
    }
    
    private func loadDefaultSound() {
        print("Audio engine ready with default sounds")
    }
    
    func playNote(_ note: UInt8, velocity: UInt8) {
        guard isSoundEnabled else { return }
        samplerNode.startNote(note, withVelocity: velocity, onChannel: 0)
    }
    
    func stopNote(_ note: UInt8) {
        guard isSoundEnabled else { return }
        samplerNode.stopNote(note, onChannel: 0)
    }
    
    func toggleSound() {
        isSoundEnabled.toggle()
    }
}
