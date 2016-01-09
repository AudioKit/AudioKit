//
//  AKTriangleInstrument.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 1/8/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation
import AVFoundation

public class AKTriangleInstrument: AKPolyphonicInstrument {
    /// Attack time
    public var attackDuration: Double = 0.1 {
        didSet {
            for voice in voices {
                let triangleVoice = voice as! AKTriangleVoice
                triangleVoice.adsr.attackDuration = attackDuration
            }
        }
    }
    /// Decay time
    public var decayDuration: Double = 0.1 {
        didSet {
            for voice in voices {
                let triangleVoice = voice as! AKTriangleVoice
                triangleVoice.adsr.decayDuration = decayDuration
            }
        }
    }
    /// Sustain Level
    public var sustainLevel: Double = 0.66 {
        didSet {
            for voice in voices {
                let triangleVoice = voice as! AKTriangleVoice
                triangleVoice.adsr.sustainLevel = sustainLevel
            }
        }
    }
    /// Release time
    public var releaseDuration: Double = 0.5 {
        didSet {
            for voice in voices {
                let triangleVoice = voice as! AKTriangleVoice
                triangleVoice.adsr.releaseDuration = releaseDuration
            }
        }
    }
    
    public init(voiceCount: Int) {
        super.init(voice: AKTriangleVoice(), voiceCount: voiceCount)
    }
    
    public override func startVoice(voice: Int, note: Int, velocity: Int) {
        let frequency = note.midiNoteToFrequency()
        let amplitude = Double(velocity) / 127.0 * 0.3
        let triangleVoice = voices[voice] as! AKTriangleVoice 
        triangleVoice.oscillator.frequency = frequency
        triangleVoice.oscillator.amplitude = amplitude
        triangleVoice.start()
    }
    public override func stopVoice(voice: Int, note: Int) {
        let triangleVoice = voices[voice] as! AKTriangleVoice //you'll need to cast the voice to its original form
        triangleVoice.stop()
    }
}

internal class AKTriangleVoice: AKVoice {
    
    /// Required property for AKNode
    var avAudioNode: AVAudioNode
    /// Required property for AKNode containing all the node's connections
    var connectionPoints = [AVAudioConnectionPoint]()
    
    var oscillator: AKTriangleOscillator
    var adsr: AKAmplitudeEnvelope
    
    init() {
        oscillator = AKTriangleOscillator()
        adsr = AKAmplitudeEnvelope(oscillator,
            attackDuration: 0.2,
            decayDuration: 0.2,
            sustainLevel: 0.8,
            releaseDuration: 1.0)

        self.avAudioNode = adsr.avAudioNode
    }
    
    /// Function create an identical new node for use in creating polyphonic instruments
    func copy() -> AKVoice {
        let copy = AKTriangleVoice()
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
