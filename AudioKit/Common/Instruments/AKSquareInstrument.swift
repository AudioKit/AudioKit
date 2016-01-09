//
//  AKSquareInstrument.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 1/8/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation
import AVFoundation

public class AKSquareInstrument: AKPolyphonicInstrument {
    
    /// Duty cycle width (range 0-1).
    public var pulseWidth: Double = 0.5 {
        didSet {
            for voice in voices {
                let squareVoice = voice as! AKSquareVoice
                squareVoice.oscillator.pulseWidth = pulseWidth
            }
        }
    }
    
    /// Attack time
    public var attackDuration: Double = 0.1 {
        didSet {
            for voice in voices {
                let squareVoice = voice as! AKSquareVoice
                squareVoice.adsr.attackDuration = attackDuration
            }
        }
    }
    /// Decay time
    public var decayDuration: Double = 0.1 {
        didSet {
            for voice in voices {
                let squareVoice = voice as! AKSquareVoice
                squareVoice.adsr.decayDuration = decayDuration
            }
        }
    }
    /// Sustain Level
    public var sustainLevel: Double = 0.66 {
        didSet {
            for voice in voices {
                let squareVoice = voice as! AKSquareVoice
                squareVoice.adsr.sustainLevel = sustainLevel
            }
        }
    }
    /// Release time
    public var releaseDuration: Double = 0.5 {
        didSet {
            for voice in voices {
                let squareVoice = voice as! AKSquareVoice
                squareVoice.adsr.releaseDuration = releaseDuration
            }
        }
    }
    
    public init(voiceCount: Int) {
        super.init(voice: AKSquareVoice(), voiceCount: voiceCount)
    }
    
    public override func startVoice(voice: Int, note: Int, velocity: Int) {
        let frequency = note.midiNoteToFrequency()
        let amplitude = Double(velocity) / 127.0 * 0.3
        let squareVoice = voices[voice] as! AKSquareVoice 
        squareVoice.oscillator.frequency = frequency
        squareVoice.oscillator.amplitude = amplitude
        squareVoice.start()
    }
    public override func stopVoice(voice: Int, note: Int) {
        let squareVoice = voices[voice] as! AKSquareVoice //you'll need to cast the voice to its original form
        squareVoice.stop()
    }
}

internal class AKSquareVoice: AKVoice {
    
    /// Required property for AKNode
    var avAudioNode: AVAudioNode
    /// Required property for AKNode containing all the node's connections
    var connectionPoints = [AVAudioConnectionPoint]()
    
    var oscillator: AKSquareWaveOscillator
    var adsr: AKAmplitudeEnvelope
    
    init() {
        oscillator = AKSquareWaveOscillator()
        adsr = AKAmplitudeEnvelope(oscillator,
            attackDuration: 0.2,
            decayDuration: 0.2,
            sustainLevel: 0.8,
            releaseDuration: 1.0)
        
        self.avAudioNode = adsr.avAudioNode
    }
    
    /// Function create an identical new node for use in creating polyphonic instruments
    func copy() -> AKVoice {
        let copy = AKSquareVoice()
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
