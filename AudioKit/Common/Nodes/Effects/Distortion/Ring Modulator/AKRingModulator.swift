//
//  AKRingModulator.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

/// AudioKit version of Apple's Ring Modulator from the Distortion Audio Unit
///
open class AKRingModulator: AKNode, AKToggleable, AUEffect, AKInput {

    // MARK: - Properties

    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(appleEffect: kAudioUnitSubType_Distortion)
    private var au: AUWrapper
    private var lastKnownMix: Double = 1

    /// Frequency1 (Hertz) ranges from 0.5 to 8000 (Default: 100)
    @objc open dynamic var frequency1: Double = 100 {
        didSet {
            frequency1 = (0.5...8_000).clamp(frequency1)
            au[kDistortionParam_RingModFreq1] = frequency1
        }
    }

    /// Frequency2 (Hertz) ranges from 0.5 to 8000 (Default: 100)
    @objc open dynamic var frequency2: Double = 100 {
        didSet {
            frequency2 = (0.5...8_000).clamp(frequency2)
            au[kDistortionParam_RingModFreq2] = frequency2
        }
    }

    /// Ring Mod Balance (Normalized Value) ranges from 0 to 1 (Default: 0.5)
    @objc open dynamic var balance: Double = 0.5 {
        didSet {
            balance = (0...1).clamp(balance)
            au[kDistortionParam_RingModBalance] = balance * 100
        }
    }

    /// Mix (Normalized Value) ranges from 0 to 1 (Default: 1)
    @objc open dynamic var mix: Double = 1 {
        didSet {
            mix = (0...1).clamp(mix)
            au[kDistortionParam_FinalMix] = mix * 100
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    @objc open dynamic var isStarted = true

    // MARK: - Initialization

    /// Initialize the ring modulator node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - frequency1: Frequency1 (Hertz) ranges from 0.5 to 8000 (Default: 100)
    ///   - frequency2: Frequency2 (Hertz) ranges from 0.5 to 8000 (Default: 100)
    ///   - balance: Balance (Normalized Value) ranges from 0 to 1 (Default: 0.5)
    ///   - mix: Mix (Normalized Value) ranges from 0 to 1 (Default: 1)
    ///
    @objc public init(
        _ input: AKNode? = nil,
        frequency1: Double = 100,
        frequency2: Double = 100,
        balance: Double = 0.5,
        mix: Double = 1) {

        self.frequency1 = frequency1
        self.frequency2 = frequency2
        self.balance = balance
        self.mix = mix

        let effect = _Self.effect
        au = AUWrapper(effect)

        super.init(avAudioUnit: effect, attach: true)

        input?.connect(to: self)

        // Since this is the Ring Modulator, mix it to 100% and use the final mix as the mix parameter
        au[kDistortionParam_RingModMix] = 100
        au[kDistortionParam_RingModFreq1] = frequency1
        au[kDistortionParam_RingModFreq2] = frequency2
        au[kDistortionParam_RingModBalance] = balance * 100
        au[kDistortionParam_FinalMix] = mix * 100
    }

    // MARK: - Control

    /// Function to start, play, or activate the node, all do the same thing
    @objc open func start() {
        if isStopped {
            mix = lastKnownMix
            isStarted = true
        }
    }

    /// Function to stop or bypass the node, both are equivalent
    @objc open func stop() {
        if isPlaying {
            lastKnownMix = mix
            mix = 0
            isStarted = false
        }
    }

    /// Disconnect the node
    override open func detach() {
        stop()
        AudioKit.detach(nodes: [self.avAudioNode])
    }
}
