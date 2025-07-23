//
//  AudioEngine.swift
//  MIDIVisualizer
//
//


import AVFoundation
import Foundation

class AudioEngine: ObservableObject {
    private var audioEngine: AVAudioEngine
    private var samplerNode: AVAudioUnitSampler
    @Published var isSoundEnabled: Bool = true
    
    init() {
        audioEngine = AVAudioEngine()
        samplerNode = AVAudioUnitSampler()
        setupAudio()
    }
    
    private func setupAudio() {
        // Configure audio session
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default)
            try audioSession.setActive(true)
        } catch {
            print("Error- Failed to setup audio session: \(error)")
        }
        
        // Attach and connect nodes
        audioEngine.attach(samplerNode)
        audioEngine.connect(samplerNode, to: audioEngine.mainMixerNode, format: nil)
        
        // Start the engine
        do {
            try audioEngine.start()
            loadDefaultSound()
        } catch {
            print("Error- Failed to start audio engine: \(error)")
        }
    }
    
    private func loadDefaultSound() {
        // Load default sine wave sound
        do {
            // Use default General MIDI sound bank
            try samplerNode.loadSoundBankInstrument(
                //Add the soundfont file if deisred
                at: Bundle.main.url(forResource: "default", withExtension: "sf2") ?? URL(fileURLWithPath: ""),
                program: 0,
                bankMSB: UInt8(kAUSampler_DefaultMelodicBankMSB),
                bankLSB: UInt8(kAUSampler_DefaultBankLSB)
            )
        } catch {
            // Use basic synthesis when file not provided
            print("Could not load sound bank, using basic synthesis")
        }
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

