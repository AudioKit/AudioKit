//
//  AKOscillatorInstrument.swift
//  AudioKit
//
//  Created by Jeff Cooper on 1/6/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation
import AVFoundation

public class AKOscillatorInstrument: AKPolyphonicInstrument {
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
    
    public init(waveform: AKTable, voiceCount: Int) {
        super.init(voice: AKOscillatorVoice(waveform: waveform), voiceCount: voiceCount)
    }
    public override func startVoice(voice: Int, note: Int, velocity: Int) {
        let frequency = note.midiNoteToFrequency()
        let amplitude = Double(velocity) / 127.0 * 0.3
        let oscillatorVoice = voices[voice] as! AKOscillatorVoice //you'll need to cast the voice to it's original form
        oscillatorVoice.oscillator.frequency = frequency
        oscillatorVoice.oscillator.amplitude = amplitude
        oscillatorVoice.start()
    }
    public override func stopVoice(voice: Int, note: Int) {
        let oscillatorVoice = voices[voice] as! AKOscillatorVoice //you'll need to cast the voice to its original form
        oscillatorVoice.stop()
    }
}

internal class AKOscillatorVoice: AKVoice {
    
    /// Required property for AKNode
    var avAudioNode: AVAudioNode
    /// Required property for AKNode containing all the node's connections
    var connectionPoints = [AVAudioConnectionPoint]()
    
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
        self.avAudioNode = adsr.avAudioNode
    }
    
    /// Function create an identical new node for use in creating polyphonic instruments
    func copy() -> AKVoice {
        let copy = AKOscillatorVoice(waveform: self.waveform)
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
