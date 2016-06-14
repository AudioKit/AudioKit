//
//  AKNoiseGenerator.swift
//  AudioKit
//
//  Created by Jeff Cooper, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation
import AVFoundation

/// Noise generator that can be played polyphonically as a mix of pink and white noise
public class AKNoiseGenerator: AKPolyphonicInstrument {
    
    /// Balance of white to pink noise
    public var whitePinkMix: Double = 0 {
        didSet {
            for noiseVoice in voices as! [AKNoiseVoice] {
                noiseVoice.whitePinkMix = whitePinkMix
            }
        }
    }
    
    /// Attack time
    public var attackDuration: Double = 0.1 {
        didSet {
            for noiseVoice in voices as! [AKNoiseVoice] {
                noiseVoice.adsr.attackDuration = attackDuration
            }
        }
    }
    /// Decay time
    public var decayDuration: Double = 0.1 {
        didSet {
            for noiseVoice in voices as! [AKNoiseVoice] {
                noiseVoice.adsr.decayDuration = decayDuration
            }
        }
    }
    /// Sustain Level
    public var sustainLevel: Double = 0.66 {
        didSet {
            for noiseVoice in voices as! [AKNoiseVoice] {
                noiseVoice.adsr.sustainLevel = sustainLevel
            }
        }
    }
    /// Release time
    public var releaseDuration: Double = 0.5 {
        didSet {
            for noiseVoice in voices as! [AKNoiseVoice] {
                noiseVoice.adsr.releaseDuration = releaseDuration
            }
        }
    }
    
    /// Initial the noise generator instrument
    ///
    /// - parameter whitePinkMix: Balance of white to pink noise
    /// - parameter voiceCount: Maximum number of simultaneous voices
    ///
    public init(whitePinkMix: Double, voiceCount: Int) {
        super.init(voice: AKNoiseVoice(whitePinkMix: whitePinkMix), voiceCount: voiceCount)
    }
    
    /// Start playback of a particular voice with MIDI style note and velocity
    ///
    /// - parameter voice: Voice to start
    /// - parameter note: MIDI Note Number
    /// - parameter velocity: MIDI Velocity (0-127)
    ///
    override public func playVoice(_ voice: AKVoice, note: Int, velocity: Int) {
        let noiseVoice = voice as! AKNoiseVoice
        noiseVoice.whiteNoise.amplitude = Double(velocity) / 127.0
        noiseVoice.pinkNoise.amplitude = Double(velocity) / 127.0
        noiseVoice.start()
    }
    
    /// Stop playback of a particular voice
    ///
    /// - parameter voice: Voice to stop
    /// - parameter note: MIDI Note Number
    ///
    override public func stopVoice(_ voice: AKVoice, note: Int) {
        let noise = voice as! AKNoiseVoice
        noise.stop()
    }
}

internal class AKNoiseVoice: AKVoice {
    
    var whiteNoise: AKWhiteNoise
    var pinkNoise: AKPinkNoise
    var noiseMix: AKDryWetMixer
    var adsr: AKAmplitudeEnvelope
    
    var whitePinkMix: Double = 0 {
        didSet {
            noiseMix.balance = whitePinkMix
        }
    }

    init(whitePinkMix: Double) {
        whiteNoise = AKWhiteNoise()
        pinkNoise = AKPinkNoise()
        noiseMix = AKDryWetMixer(whiteNoise, pinkNoise, balance: whitePinkMix)
        adsr = AKAmplitudeEnvelope(noiseMix,
            attackDuration: 0.2,
            decayDuration: 0.2,
            sustainLevel: 0.8,
            releaseDuration: 1.0)
        
        self.whitePinkMix = whitePinkMix
        
        super.init()
        avAudioNode = adsr.avAudioNode
    }
    
    /// Function create an identical new node for use in creating polyphonic instruments
    override func duplicate() -> AKVoice {
        let copy = AKNoiseVoice(whitePinkMix: whitePinkMix)
        return copy
    }
    
    /// Tells whether the node is processing (ie. started, playing, or active)
    override var isStarted: Bool {
        return whiteNoise.isPlaying
    }
    
    /// Function to start, play, or activate the node, all do the same thing
    override func start() {
        whiteNoise.start()
        pinkNoise.start()
        adsr.start()
    }
    
    /// Function to stop or bypass the node, both are equivalent
    override func stop() {
        adsr.stop()
    }
}
