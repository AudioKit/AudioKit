//
//  AKFMOscillatorInstrument.swift
//  AudioKit
//
//  Created by Jeff Cooper on 1/6/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation
import AVFoundation

public class AKFMOscillatorInstrument: AKPolyphonicInstrument {
    public init(voiceCount: Int) {
        super.init(voice: AKFMOscillatorVoice(), voiceCount: voiceCount)
        for voice in voices {
            let fmVoice = voice as! AKFMOscillatorVoice
            fmVoice.oscillator.modulatingMultiplier = 4 //just some arbitrary default values
            fmVoice.oscillator.modulationIndex = 10
        }
    }
    public override func startVoice(voice: Int, note: Int, velocity: Int) {
        let fmVoice = voices[voice] as! AKFMOscillatorVoice //you'll need to cast the voice to it's original form
        fmVoice.oscillator.baseFrequency = note.midiNoteToFrequency()
        fmVoice.oscillator.amplitude = Double(velocity) / 127.0
        fmVoice.start()
    }
    public override func stopVoice(voice: Int, note: Int) {
        let fmVoice = voices[voice] as! AKFMOscillatorVoice //you'll need to cast the voice to it's original form
        fmVoice.stop()
    }
    
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
}

internal class AKFMOscillatorVoice: AKVoice {
    
    /// Required property for AKNode
    var avAudioNode: AVAudioNode
    /// Required property for AKNode containing all the node's connections
    var connectionPoints = [AVAudioConnectionPoint]()
    
    var oscillator: AKFMOscillator
    var adsr: AKAmplitudeEnvelope
    
    init() {
        oscillator = AKFMOscillator()
        adsr = AKAmplitudeEnvelope(oscillator, attackDuration: 0.2, decayDuration: 0.2, sustainLevel: 0.8, releaseDuration: 1.0)
        self.avAudioNode = adsr.avAudioNode
    }
    
    /// Function create an identical new node for use in creating polyphonic instruments
    func copy() -> AKVoice {
        let copy = AKFMOscillatorVoice()
        return copy
    }
    
    /// Tells whether the node is processing (ie. started, playing, or active)
    var isStarted: Bool {
        return oscillator.isPlaying
    }
    
    /// Function to start, play, or activate the node, all do the same thing
    func start() {
        oscillator.start()
        adsr.start()
    }
    
    /// Function to stop or bypass the node, both are equivalent
    func stop() {
        adsr.stop()
    }
}