//
//  AKPeakLimiter.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

/// AudioKit version of Apple's PeakLimiter Audio Unit
///
open class AKPeakLimiter: AKNode, AKToggleable, AUEffect {

    public static let ComponentDescription = AudioComponentDescription(appleEffect: kAudioUnitSubType_PeakLimiter)

    private var au: AUWrapper
    private var mixer: AKMixer

    /// Attack Time (Secs) ranges from 0.001 to 0.03 (Default: 0.012)
    open dynamic var attackTime: Double = 0.012 {
        didSet {
            attackTime = (0.001...0.03).clamp(attackTime)
            au[kLimiterParam_AttackTime] = attackTime
        }
    }

    /// Decay Time (Secs) ranges from 0.001 to 0.06 (Default: 0.024)
    open dynamic var decayTime: Double = 0.024 {
        didSet {
            decayTime = (0.001...0.06).clamp(decayTime)
            au[kLimiterParam_DecayTime] = decayTime
        }
    }

    /// Pre Gain (dB) ranges from -40 to 40 (Default: 0)
    open dynamic var preGain: Double = 0 {
        didSet {
            preGain = (-40...40).clamp(preGain)
            au[kLimiterParam_PreGain] = preGain
        }
    }

    /// Dry/Wet Mix (Default 100)
    open dynamic var dryWetMix: Double = 100 {
        didSet {
            dryWetMix = (0...100).clamp(dryWetMix)
            inputGain?.volume = 1 - dryWetMix / 100
            effectGain?.volume = dryWetMix / 100
        }
    }

    private var lastKnownMix: Double = 100
    private var inputGain: AKMixer?
    private var effectGain: AKMixer?
    
    // Store the internal effect
    fileprivate var internalEffect: AVAudioUnitEffect

    /// Tells whether the node is processing (ie. started, playing, or active)
    open dynamic var isStarted = true

    /// Initialize the peak limiter node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - attackTime: Attack Time (Secs) ranges from 0.001 to 0.03 (Default: 0.012)
    ///   - decayTime: Decay Time (Secs) ranges from 0.001 to 0.06 (Default: 0.024)
    ///   - preGain: Pre Gain (dB) ranges from -40 to 40 (Default: 0)
    ///
    public init(
        _ input: AKNode?,
        attackTime: Double = 0.012,
        decayTime: Double = 0.024,
        preGain: Double = 0) {

            self.attackTime = attackTime
            self.decayTime = decayTime
            self.preGain = preGain

            inputGain = AKMixer(input)
            inputGain?.volume = 0
            mixer = AKMixer(inputGain)

            effectGain = AKMixer(input)
            effectGain?.volume = 1

            let effect = _Self.effect
            self.internalEffect = effect
        
            au = AUWrapper(effect)

            super.init(avAudioNode: mixer.avAudioNode)
            AudioKit.engine.attach(effect)

            if let node = effectGain?.avAudioNode {
                AudioKit.engine.connect(node, to: effect, format: AudioKit.format)
            }
            AudioKit.engine.connect(effect, to: mixer.avAudioNode, format: AudioKit.format)

            au[kLimiterParam_AttackTime] = attackTime
            au[kLimiterParam_DecayTime] = decayTime
            au[kLimiterParam_PreGain] = preGain
    }

    // MARK: - Control

    /// Function to start, play, or activate the node, all do the same thing
    open func start() {
        if isStopped {
            dryWetMix = lastKnownMix
            isStarted = true
        }
    }

    /// Function to stop or bypass the node, both are equivalent
    open func stop() {
        if isPlaying {
            lastKnownMix = dryWetMix
            dryWetMix = 0
            isStarted = false
        }
    }
    
    /// Disconnect the node
    override open func disconnect() {
        stop()
        
        disconnect(nodes: [inputGain!.avAudioNode, effectGain!.avAudioNode, mixer.avAudioNode])
        AudioKit.engine.detach(self.internalEffect)
    }
}
