//
//  AKFMSynth.swift
//  AudioKit
//
//  Created by Jeff Cooper, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation
import AVFoundation

/// A wrapper for AKFMOscillator to make it playable as a polyphonic instrument.
public class AKFMSynth: AKPolyphonicInstrument {
    /// This multiplied by the baseFrequency gives the carrier frequency.
    public var carrierMultiplier: Double = 1.0 {
        didSet {
            for voice in voices {
                let fmVoice = voice as! AKFMOscillatorVoice
                fmVoice.oscillator.carrierMultiplier = carrierMultiplier
            }
        }
    }
    /// This multiplied by the baseFrequency gives the modulating frequency.
    public var modulatingMultiplier: Double = 1 {
        didSet {
            for voice in voices {
                let fmVoice = voice as! AKFMOscillatorVoice
                fmVoice.oscillator.modulatingMultiplier = modulatingMultiplier
            }
        }
    }
    /// This multiplied by the modulating frequency gives the modulation amplitude.
    public var modulationIndex: Double = 1 {
        didSet {
            for voice in voices {
                let fmVoice = voice as! AKFMOscillatorVoice
                fmVoice.oscillator.modulationIndex = modulationIndex
            }
        }
    }
    
    /// Attack time
    public var attackDuration: Double = 0.1 {
        didSet {
            for voice in voices {
                let fmVoice = voice as! AKFMOscillatorVoice
                fmVoice.adsr.attackDuration = attackDuration
            }
        }
    }
    /// Decay time
    public var decayDuration: Double = 0.1 {
        didSet {
            for voice in voices {
                let fmVoice = voice as! AKFMOscillatorVoice
                fmVoice.adsr.decayDuration = decayDuration
            }
        }
    }
    /// Sustain Level
    public var sustainLevel: Double = 0.66 {
        didSet {
            for voice in voices {
                let fmVoice = voice as! AKFMOscillatorVoice
                fmVoice.adsr.sustainLevel = sustainLevel
            }
        }
    }
    /// Release time
    public var releaseDuration: Double = 0.5 {
        didSet {
            for voice in voices {
                let fmVoice = voice as! AKFMOscillatorVoice
                fmVoice.adsr.releaseDuration = releaseDuration
            }
        }
    }
    
    /// Instantiate the FM Oscillator Instrument
    ///
    /// - parameter voiceCount: Maximum number of voices that will be required
    ///
    public init(voiceCount: Int) {
        super.init(voice: AKFMOscillatorVoice(), voiceCount: voiceCount)
        for voice in voices {
            let fmVoice = voice as! AKFMOscillatorVoice
            fmVoice.oscillator.modulatingMultiplier = 4 //just some arbitrary default values
            fmVoice.oscillator.modulationIndex = 10
        }
    }
    
    /// Start a given voice playing a note.
    ///
    /// - parameter voice: Voice to start
    /// - parameter note: MIDI Note Number to start
    /// - parameter velocity: MIDI Velocity (0-127) to trigger the note at
    ///
    public override func playVoice(voice: AKVoice, note: Int, velocity: Int) {
        let fmVoice = voice as! AKFMOscillatorVoice
        fmVoice.oscillator.baseFrequency = note.midiNoteToFrequency()
        fmVoice.oscillator.amplitude = Double(velocity) / 127.0
        fmVoice.start()
    }
    
    /// Stop a given voice playing a note.
    ///
    /// - parameter voice: Voice to stop
    /// - parameter note: MIDI Note Number to stop
    ///
    public override func stopVoice(voice: AKVoice, note: Int) {
        let fmVoice = voice as! AKFMOscillatorVoice 
        fmVoice.stop()
    }
}

internal class AKFMOscillatorVoice: AKVoice {
    
    var oscillator: AKFMOscillator
    var adsr: AKAmplitudeEnvelope
    
    /// Instantiate the FM Oscillator Voice
    override init() {
        oscillator = AKFMOscillator()
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
        let copy = AKFMOscillatorVoice()
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
