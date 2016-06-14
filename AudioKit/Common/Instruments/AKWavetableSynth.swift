//
//  AKWavetableSynth.swift
//  AudioKit
//
//  Created by Jeff Cooper, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation
import AVFoundation

/// A wrapper for AKOscillator to make it playable as a polyphonic instrument.
public class AKWavetableSynth: AKPolyphonicInstrument {
    /// Attack time
    public var attackDuration: Double = 0.1 {
        didSet {
            for voice in voices {
                let oscillatorVoice = voice as! AKOscillatorVoice
                oscillatorVoice.adsr.attackDuration = attackDuration
            }
        }
    }
    /// Decay time
    public var decayDuration: Double = 0.1 {
        didSet {
            for voice in voices {
                let oscillatorVoice = voice as! AKOscillatorVoice
                oscillatorVoice.adsr.decayDuration = decayDuration
            }
        }
    }
    /// Sustain Level
    public var sustainLevel: Double = 0.66 {
        didSet {
            for voice in voices {
                let oscillatorVoice = voice as! AKOscillatorVoice
                oscillatorVoice.adsr.sustainLevel = sustainLevel
            }
        }
    }
    /// Release time
    public var releaseDuration: Double = 0.5 {
        didSet {
            for voice in voices {
                let oscillatorVoice = voice as! AKOscillatorVoice
                oscillatorVoice.adsr.releaseDuration = releaseDuration
            }
        }
    }
    
    /// Instantiate the Oscillator Instrument
    ///
    /// - parameter waveform: Shape of the waveform to oscillate
    /// - parameter voiceCount: Maximum number of voices that will be required
    ///
    public init(waveform: AKTable, voiceCount: Int) {
        super.init(voice: AKOscillatorVoice(waveform: waveform), voiceCount: voiceCount)
    }
    
    /// Start playback of a particular voice with MIDI style note and velocity
    ///
    /// - parameter voice: Voice to start
    /// - parameter note: MIDI Note Number
    /// - parameter velocity: MIDI Velocity (0-127)
    ///
    override public func playVoice(_ voice: AKVoice, note: Int, velocity: Int) {
        let frequency = note.midiNoteToFrequency()
        let amplitude = Double(velocity) / 127.0 * 0.3
        let oscillatorVoice = voice as! AKOscillatorVoice
        oscillatorVoice.oscillator.frequency = frequency
        oscillatorVoice.oscillator.amplitude = amplitude
        oscillatorVoice.start()
    }
    
    /// Stop playback of a particular voice
    ///
    /// - parameter voice: Voice to stop
    /// - parameter note: MIDI Note Number
    ///
    override public func stopVoice(_ voice: AKVoice, note: Int) {
        let oscillatorVoice = voice as! AKOscillatorVoice 
        oscillatorVoice.stop()
    }
}

internal class AKOscillatorVoice: AKVoice {
    
    var oscillator: AKOscillator
    var adsr: AKAmplitudeEnvelope
    
    var waveform: AKTable
    
    init(waveform: AKTable) {
        oscillator = AKOscillator(waveform: waveform)
        adsr = AKAmplitudeEnvelope(oscillator,
            attackDuration: 0.2,
            decayDuration: 0.2,
            sustainLevel: 0.8,
            releaseDuration: 1.0)
        
        self.waveform = waveform
        super.init()
        
        avAudioNode = adsr.avAudioNode
    }
    
    /// Function create an identical new node for use in creating polyphonic instruments
    override func duplicate() -> AKVoice {
        let copy = AKOscillatorVoice(waveform: self.waveform)
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
