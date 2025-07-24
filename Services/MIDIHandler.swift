//
//  MIDIHandler.swift
//  MIDIVisualizer
//
//


import CoreMIDI
import SwiftUI

protocol MIDIHandlerDelegate: AnyObject {
    func midiNoteOn(note: UInt8, velocity: UInt8)
    func midiNoteOff(note: UInt8)
}

class MIDIHandler: ObservableObject {
    weak var delegate: MIDIHandlerDelegate?
    weak var audioEngine: AudioEngine?
    
    private var midiClient: MIDIClientRef = 0
    private var virtualSource: MIDIEndpointRef = 0
    private var virtualDestination: MIDIEndpointRef = 0
    
    // MIDI note range for virtual keyboard- C4 to B4
    let noteRange: ClosedRange<UInt8> = 60...71
    
    // Note names to be displayed
    let noteNames = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
    
    func setupMIDI() {
        // Create MIDI client
        let clientName = "MIDIVisualizerClient" as CFString
        let status = MIDIClientCreateWithBlock(clientName, &midiClient) { notificationPointer in
                 // MIDI notifications
                 let notification = notificationPointer.pointee
                     switch notification.messageID {
                     case .msgSetupChanged:
                         print("MIDI setup changed")
                     default:
                         print("Received MIDI notification: \(notification.messageID)")
                     }
             }
        
        guard status == noErr else {
            print("Failed to create MIDI client: \(status)")
            return
        }
        
        // Create virtual MIDI SOURCE
        let sourceName = "MIDI Visualizer Source" as CFString
        MIDISourceCreate(midiClient, sourceName, &virtualSource)
        
        // Create virtual MIDI DESTINATION
        let destName = "MIDI Visualizer Destination" as CFString
        MIDIDestinationCreateWithBlock(midiClient, destName, &virtualDestination) { [weak self] packetList, _ in
            self?.handleMIDIPackets(packetList)
        }
    }
    
    private func handleMIDIPackets(_ packetListPointer: UnsafePointer<MIDIPacketList>) {
        let packetList = packetListPointer.pointee
        var packet = packetList.packet
        
        for _ in 0..<packetList.numPackets {
            let bytes = Mirror(reflecting: packet.data).children.map { $0.value as! UInt8 }
            
            if packet.length > 0 {
                let status = bytes[0] & 0xF0
                
                switch status {
                case 0x90: // Note On
                    if packet.length >= 3 {
                        let note = bytes[1]
                        let velocity = bytes[2]
                        if velocity > 0 {
                            DispatchQueue.main.async {
                                self.delegate?.midiNoteOn(note: note, velocity: velocity)
                            }
                        } else {
                            // Note On with velocity 0 == Note Off
                            DispatchQueue.main.async {
                                self.delegate?.midiNoteOff(note: note)
                            }
                        }
                    }
                case 0x80: // Note Off
                    if packet.length >= 3 {
                        let note = bytes[1]
                        DispatchQueue.main.async {
                            self.delegate?.midiNoteOff(note: note)
                        }
                    }
                default:
                    break
                }
            }
            
            // Move to next packet
            packet = MIDIPacketNext(&packet).pointee
        }
    }
    
    // Send MIDI Note On
    func sendNoteOn(note: UInt8, velocity: UInt8, channel: UInt8 = 0) {
        var packetList = MIDIPacketList()
        var packet = MIDIPacketListInit(&packetList)
        
        let noteOnMessage: [UInt8] = [0x90 | channel, note, velocity]
        packet = MIDIPacketListAdd(&packetList, 1024, packet, 0, noteOnMessage.count, noteOnMessage)
        
        MIDIReceived(virtualDestination, &packetList)
        
        // Also call delegate directly for immediate visualization
        DispatchQueue.main.async { [weak self] in
            self?.delegate?.midiNoteOn(note: note, velocity: velocity)
        }
    }
    
    // Send MIDI Note Off
    func sendNoteOff(note: UInt8, channel: UInt8 = 0) {
        var packetList = MIDIPacketList()
        var packet = MIDIPacketListInit(&packetList)
        
        let noteOffMessage: [UInt8] = [0x80 | channel, note, 64] // Default release velocity
        packet = MIDIPacketListAdd(&packetList, 1024, packet, 0, noteOffMessage.count, noteOffMessage)
        
        MIDIReceived(virtualDestination, &packetList)
        
        // Also call delegate directly for immediate visualization
        DispatchQueue.main.async { [weak self] in
            self?.delegate?.midiNoteOff(note: note)
        }
    }
    
    // Play a demo sequence
    func playDemoSequence() {
        Task {
            // Simple melody: C-E-G-E-C (C major arpeggio)
            let melody: [(note: UInt8, duration: Double)] = [
                (60, 0.5), // C4
                (64, 0.5), // E4
                (67, 0.5), // G4
                (64, 0.5), // E4
                (60, 1.0), // C4
            ]
            
            for (note, duration) in melody {
                sendNoteOn(note: note, velocity: 80)
                audioEngine?.playNote(note, velocity: 80)
                try? await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))
                sendNoteOff(note: note)
                audioEngine?.stopNote(note)
                try? await Task.sleep(nanoseconds: 100_000_000) // Small gap between notes
            }
        }
    }
    
    func getNoteName(for note: UInt8) -> String {
        let noteIndex = Int(note % 12)
        let octave = Int(note / 12) - 1
        return "\(noteNames[noteIndex])\(octave)"
    }
    
    deinit {
        if virtualSource != 0 {
            MIDIEndpointDispose(virtualSource)
        }
        if virtualDestination != 0 {
            MIDIEndpointDispose(virtualDestination)
        }
        if midiClient != 0 {
            MIDIClientDispose(midiClient)
        }
    }
}
