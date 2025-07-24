# 🎹 MIDI Visualizer 

A clean, real-time MIDI visualization app for iOS / macOS that transforms musical notes into animated visual elements. Built with SwiftUI, Core MIDI and AVFoundation, this app demonstrates modern development practices and creative audio-visual programming.


https://github.com/user-attachments/assets/65da7714-52f4-457a-825e-0fb4e945e174



## 🎯 Overview

MIDI Visualizer provides an interactive music visualization experience. The app features a virtual piano keyboard that generates MIDI events, which are then visualized as animated shapes with properties mapped to musical characteristics:

- **Pitch → Vertical Position**: Higher notes appear higher on screen
- **Velocity → Size & Color Intensity**: Harder key presses create larger, more vibrant visuals
- **Note Duration → Animation Length**: Visual elements fade out after note release

## 🚀 Features

- 🎹 **Virtual Piano Keyboard**: Interactive on-screen keyboard (C4-B4) with properly positioned black keys
- 🎨 **Multiple Visualization Styles**: 
 - **Circles**: Notes appear as colored circles positioned by pitch with note names
 - **Bars**: Vertical bars showing all chromatic notes (C4-B4) with velocity-based height
- 🌈 **Customizable Color Schemes**: Rainbow (default), Fire, and Ocean themes
- ⚡ **Real-time Performance**: Smooth 60fps animations synchronized with MIDI input
- 🎵 **Demo Playback**: Built-in C major arpeggio for easy demonstration
- 🔊 **Optional Audio Feedback**: Toggle sound on/off in settings
- ⚙️ **Adjustable Settings**: Control animation speed and visual preferences

## 🏗 Architecture

The app follows **MVVM (Model-View-ViewModel)** architecture with clear separation of concerns:

```
MIDIVisualizer/
├── App Layer
│   └── MIDIVisualizerApp.swift      # App entry point
├── Views
│   ├── ContentView.swift            # Main container view
│   ├── VisualizerView.swift         # Visualization rendering
│   ├── VirtualKeyboardView.swift    # Piano keyboard UI
│   └── SettingsView.swift           # Settings interface
├── ViewModels
│   └── VisualizerViewModel.swift    # Business logic & state management
└── Services
    ├── MIDIHandler.swift            # Core MIDI integration
    └── AudioEngine.swift            # Audio playback (optional)
```

## MIDIHandler.swift
Handles all Core MIDI functionality, creating virtual endpoints and processing MIDI events.
### Key Properties:

- midiClient: Core MIDI client reference
- virtualSource/Destination: MIDI endpoints for sending/receiving
- noteRange: C4-B4 (MIDI notes 60-71)

### Key Functions:

- setupMIDI(): Creates MIDI client and virtual endpoints
- sendNoteOn(note:velocity:channel:): Generates Note On events with direct delegate callback
- sendNoteOff(note:channel:): Generates Note Off events
- handleMIDIPackets(_:): Processes incoming MIDI data
- playDemoSequence(): Plays a pre-programmed C major arpeggio with audio

### Protocol:

- MIDIHandlerDelegate: Interface for receiving MIDI events

## VisualizerViewModel.swift
Manages visualization state and transforms MIDI events into visual representations.
### Key Properties:

- activeNotes: Array of currently visible note visualizations
- visualizationStyle: Current visualization mode (circles/bars)
- colorScheme: Active color theme (Rainbow default, Fire, Ocean)
- animationSpeed: Controls fade-out duration

### Key Functions:

- midiNoteOn(note:velocity:): Creates new visualization for note
- midiNoteOff(note:): Triggers fade-out animation
- calculateRadius(for:): Maps velocity to circle size (10-50pt)
- getColor(for:velocity:): Determines color based on scheme and note

### Data Model:

- NoteVisualization: Represents a visual element with pitch, velocity, size, color, and opacity

## VisualizerView.swift
Renders the actual visualizations based on the current style and active notes.
### Key Components:

- CircleVisualizationView: Displays notes as positioned circles with note names
- BarVisualizationView: Shows chromatic scale (C4-B4) as vertical bars
- BackgroundGridView: Optional grid overlay

### Key Functions:

- calculateXPosition(for:in:): Maps pitch to horizontal position
- calculateYPosition(for:in:): Maps MIDI pitch (0-127) to vertical position
- calculateBarHeight(for:): Maps velocity to bar height (40-200pt)

### Updates:

- Circle view shows note names that move with the circles
- Bar view displays all 12 chromatic notes with proper spacing

## VirtualKeyboardView.swift
Implements the interactive piano keyboard with proper touch handling.
### Key Components:

- WhiteKeyView: Renders white keys with touch states
- BlackKeyView: Renders black keys with correct positioning between white keys

### Key Properties:

- whiteKeys: Array of MIDI notes for white keys [60,62,64,65,67,69,71]
- blackKeys: Individual positioning for C#4, D#4, F#4, G#4, A#4

### Key Functions:

- handleKeyPress(_:): Sends Note On with random velocity (60-100) and triggers audio
- handleKeyRelease(_:): Sends Note Off and stops audio

## SettingsView.swift
Provides user customization options in a modal sheet.
### Sections:

- Visualization Style (Circles/Bars)
- Color Scheme (Rainbow/Fire/Ocean)
- Animation Speed (0.5x-2.0x)
- Background Grid Toggle
- Sound Enable/Disable

## AudioEngine.swift
Simple audio feedback system using AVFoundation.
### Key Functions:

- playNote(_:velocity:): Plays a sound for the given note
- stopNote(_:): Stops the sound for a note
- toggleSound(): Enables/disables audio feedback

## Understanding the Visuals
- Horizontal Position: Represents the note (C through B)
- Vertical Position: Higher pitch = higher on screen
- Size: Larger shapes = higher velocity (louder)
- Color Intensity: Brighter = higher velocity
- Fade Out: Happens after note release
- Note Names: Displayed on circles for easy identification

## 🛠 Technical Requirements
- iOS 16.0+ (Deployment target)
- macOS Version: macOS 13.0+ (Deployment target)
- Xcode 16.0+ (Development)
- Swift 5.9+
- Frameworks: SwiftUI, Core MIDI, AVFoundation

## 🖥️ Cross-Platform Support
- **iOS**: Full support with touch interactions
- **macOS**: Mouse-based interaction (click to play notes)


## 🔧 Current Limitations & Design Choices

### Simulated Features
- **Velocity/Pressure**: Currently randomized (60-100) for each key press
  - Real devices could use 3D Touch/Haptic Touch for actual pressure sensitivity
  - Demonstrates the visual system's response to different velocities

- **MIDI Implementation**: Virtual MIDI endpoints only
  - No external MIDI device support (yet), for demonstration without hardware requirements
  - Core MIDI framework is properly implemented for future expansion

- **Audio Engine**: Basic implementation using system sounds
  - Focused on visualization rather than synthesis
  - Can be enhanced with proper sampler or synthesizer

### Why?
1. **Portfolio Accessibility**: Anyone can run and test without MIDI hardware
2. **Visual Focus**: Emphasizes the visualization system over audio complexity
3. **Simulator Friendly**: Full functionality in Xcode Simulator for easy demos
4. **Expandability**: Architecture supports adding real features later

