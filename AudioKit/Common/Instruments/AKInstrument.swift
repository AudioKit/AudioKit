//
//  AKInstrument.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation
import AVFoundation

/// Parent class for nodes that can be included in a polyphonic instrument
public class AKVoice: AKNode, AKToggleable {

    /// Required for the AKToggleable protocol
    public var isStarted: Bool {
        return false
        // override in subclass
    }

    /// Function to start, play, or activate the node, all do the same thing
    public func start() {
        // override in subclass
    }

    /// Function to stop or bypass the node, both are equivalent
    public func stop() {
        // override in subclass
    }

    /// Return a duplication of this voice
    public func duplicate() -> AKVoice {
        return AKVoice()
        // override in subclass
    }
}

/// This class is for generator nodes that consist of a number of voices that
/// can be played simultaneously for polyphony
public class AKPolyphonicInstrument: AKNode {

    // MARK: - Voice Properties

    /// Array of all voices
    public var voices: [AKVoice] {
        return activeVoices + availableVoices
    }

    /// Array of available voices
    public var availableVoices = [AKVoice]()

    /// Array of only voices currently playing
    public var activeVoices = [AKVoice]()

    /// Array of notes being played on the active instruments
    public var activeNotes = [Int]()

    var voiceCount: Int

    // MARK: - Output properties

    private let output = AKMixer()

    /// Output level
    public var volume: Double = 1.0 {
        didSet {
            output.volume = volume
            amplitude = volume
        }
    }

    /// Alias for volume
    public var amplitude: Double = 1.0 {
        didSet {
            output.volume = amplitude
        }
    }

    // MARK: - Initialization

    /// Initialize the polyphonic instrument with a voice and a count
    ///
    /// - Parameters:
    ///   - voice: Template voice which will be copied
    ///   - voiceCount: Maximum number of simultaneous voices
    ///
    public init(voice: AKVoice, voiceCount: Int = 1) {

        self.voiceCount = voiceCount

        super.init()
        avAudioNode = output.avAudioNode

        for _ in 0 ..< voiceCount {
            let voice = voice.duplicate()
            availableVoices.append(voice)
            output.connect(voice)
        }
    }

    // MARK: - Playback control

    /// Start playback with MIDI style note and velocity
    ///
    /// - Parameters:
    ///   - note: MIDI Note Number
    ///   - velocity: MIDI Velocity (0-127)
    ///
    public func playNote(note: Int, velocity: Int) {
        if let voice = availableVoices.popLast() {
            activeVoices.append(voice)
            activeNotes.append(note)
            playVoice(voice, note: note, velocity: velocity)
        }
    }

    /// Stop playback of a particular note
    ///
    /// - parameter note: MIDI Note Number
    ///
    public func stopNote(note: Int) {
        if let index  = activeNotes.indexOf(note) {
            let voice = activeVoices.removeAtIndex(index)
            voice.stop()
            availableVoices.insert(voice, atIndex: 0)
            activeNotes.removeAtIndex(index)
        }
    }

    /// Start playback of a particular voice with MIDI style note and velocity
    ///
    /// - Parameters:
    ///   - voice: Voice to start
    ///   - note: MIDI Note Number
    ///   - velocity: MIDI Velocity (0-127)
    ///
    public func playVoice(voice: AKVoice, note: Int, velocity: Int) {
        // Override in subclass
        print("Voice playing is \(voice) - note:\(note) - vel:\(velocity)")
    }

    /// Stop playback of a particular voice
    ///
    /// - Parameters:
    ///   - voice: Voice to stop
    ///   - note: MIDI Note Number
    ///
    public func stopVoice(voice: AKVoice, note: Int) {
        /// Override in subclass
        print("Stopping voice\(voice) - note:\(note)")
    }

    /// Stop all voices
    public func panic() {
        for voice in voices {
            voice.stop()
            availableVoices.append(voice)
        }
        activeVoices.removeAll()
    }
}
