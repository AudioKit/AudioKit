//
//  File.swift
//  AudioKit For iOS
//
//  Created by Jeff Cooper on 1/6/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation
import AVFoundation

public class AKNoiseInstrument: AKMidiInstrument{
    
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
    
    public init(whitePinkMix: Double, voiceCount: Int) {
        super.init(voice: AKNoiseVoice(whitePinkMix: whitePinkMix), voiceCount: voiceCount)
    }
    
    public override func startVoice(voice: Int, note: UInt8, withVelocity velocity: UInt8, onChannel channel: UInt8) {
        let noiseVoice = voices[voice] as! AKNoiseVoice
        noiseVoice.whiteNoise.amplitude = Double(velocity) / 127.0
        noiseVoice.pinkNoise.amplitude = Double(velocity) / 127.0
        noiseVoice.start()
    }
    
    public override func stopVoice(voice: Int, note: UInt8, onChannel channel: UInt8) {
        let noise = voices[voice] as! AKNoiseVoice
        noise.stop()
    }
}

internal class AKNoiseVoice: AKVoice {
    
    /// Required property for AKNode
    var avAudioNode: AVAudioNode
    /// Required property for AKNode containing all the node's connections
    var connectionPoints = [AVAudioConnectionPoint]()
    
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
        noiseMix = AKDryWetMixer(whiteNoise, pinkNoise, t: whitePinkMix)
        adsr = AKAmplitudeEnvelope(noiseMix, attackDuration: 0.2, decayDuration: 0.2, sustainLevel: 0.8, releaseDuration: 1.0)
        
        self.whitePinkMix = whitePinkMix
        self.avAudioNode = adsr.avAudioNode
    }
    
    /// Function create an identical new node for use in creating polyphonic instruments
    func copy() -> AKVoice {
        let copy = AKNoiseVoice(whitePinkMix: whitePinkMix)
        return copy
    }
    
    /// Tells whether the node is processing (ie. started, playing, or active)
    var isStarted: Bool {
        return whiteNoise.isPlaying
    }
    
    /// Function to start, play, or activate the node, all do the same thing
    func start() {
        whiteNoise.start()
        pinkNoise.start()
        adsr.start()
    }
    
    /// Function to stop or bypass the node, both are equivalent
    func stop() {
        adsr.stop()
    }
}
