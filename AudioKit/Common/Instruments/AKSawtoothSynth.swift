//
//  AKSawtoothSynth.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation
import AVFoundation

/// A wrapper for AKSawtoothVoice to make it playable as a polyphonic instrument.
public class AKSawtoothSynth: AKPolyphonicInstrument {
    /// Attack time
    public var attackDuration: Double = 0.1 {
        didSet {
            for voice in voices {
                let sawtoothVoice = voice as! AKSawtoothVoice
                sawtoothVoice.adsr.attackDuration = attackDuration
            }
        }
    }
    /// Decay time
    public var decayDuration: Double = 0.1 {
        didSet {
            for voice in voices {
                let sawtoothVoice = voice as! AKSawtoothVoice
                sawtoothVoice.adsr.decayDuration = decayDuration
            }
        }
    }
    /// Sustain Level
    public var sustainLevel: Double = 0.66 {
        didSet {
            for voice in voices {
                let sawtoothVoice = voice as! AKSawtoothVoice
                sawtoothVoice.adsr.sustainLevel = sustainLevel
            }
        }
    }
    /// Release time
    public var releaseDuration: Double = 0.5 {
        didSet {
            for voice in voices {
                let sawtoothVoice = voice as! AKSawtoothVoice
                sawtoothVoice.adsr.releaseDuration = releaseDuration
            }
        }
    }
    
    /// Instantiate the Sawtooth Instrument
    ///
    /// - parameter voiceCount: Maximum number of voices that will be required
    ///
    public init(voiceCount: Int) {
        super.init(voice: AKSawtoothVoice(), voiceCount: voiceCount)
    }
    
    /// Start playback of a particular voice with MIDI style note and velocity
    ///
    /// - parameter voice: Voice to start
    /// - parameter note: MIDI Note Number
    /// - parameter velocity: MIDI Velocity (0-127)
    ///
    override internal func playVoice(voice: AKVoice, note: Int, velocity: Int) {
        let frequency = note.midiNoteToFrequency()
        let amplitude = Double(velocity) / 127.0 * 0.3
        let sawtoothVoice = voice as! AKSawtoothVoice
        sawtoothVoice.oscillator.frequency = frequency
        sawtoothVoice.oscillator.amplitude = amplitude
        sawtoothVoice.start()
    }
    
    /// Stop playback of a particular voice
    ///
    /// - parameter voice: Voice to stop
    /// - parameter note: MIDI Note Number
    ///
    override internal func stopVoice(voice: AKVoice, note: Int) {
        let sawtoothVoice = voice as! AKSawtoothVoice //you'll need to cast the voice to its original form
        sawtoothVoice.stop()
    }
}

internal class AKSawtoothVoice: AKVoice {
    
    var oscillator: AKSawtoothOscillator
    var adsr: AKAmplitudeEnvelope
    
    override init() {
        oscillator = AKSawtoothOscillator()
        adsr = AKAmplitudeEnvelope(oscillator,
            attackDuration: 0.2,
            decayDuration: 0.2,
            sustainLevel: 0.8,
            releaseDuration: 1.0)
        
        super.init()
        avAudioNode = adsr.avAudioNode
    }
    
    /// Function create an identical new node for use in creating polyphonic instruments
    override func duplicate() -> AKVoice {
        let copy = AKSawtoothVoice()
        return copy
    }
    
    /// Tells whether the node is processing (ie. started, playing, or active)
    override var isStarted: Bool {
        return oscillator.isPlaying
    }
    
    /// Function to start, play, or activate the node, all do the same thing
    override func start() {
        oscillator.start()
        adsr.start()
    }
    
    /// Function to stop or bypass the node, both are equivalent
    override func stop() {
        adsr.stop()
    }
}
