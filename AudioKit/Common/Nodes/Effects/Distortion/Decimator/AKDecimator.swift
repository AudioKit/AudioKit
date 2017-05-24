//
//  AKDecimator.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

/// AudioKit version of Apple's Decimator from the Distortion Audio Unit
///
open class AKDecimator: AKNode, AKToggleable, AUEffect {
    // MARK: - Properties

    public static let ComponentDescription = AudioComponentDescription(appleEffect: kAudioUnitSubType_Distortion)

    private var au: AUWrapper
    private var lastKnownMix: Double = 1

    /// Decimation (Normalized Value) ranges from 0 to 1 (Default: 0.5)
    open dynamic var decimation: Double = 0.5 {
        didSet {
            decimation = (0...1).clamp(decimation)
            au[kDistortionParam_Decimation] = decimation * 100
        }
    }

    /// Rounding (Normalized Value) ranges from 0 to 1 (Default: 0)
    open dynamic var rounding: Double = 0 {
        didSet {
            rounding = (0...1).clamp(rounding)
            au[kDistortionParam_Rounding] = rounding * 100
        }
    }

    /// Mix (Normalized Value) ranges from 0 to 1 (Default: 1)
    open dynamic var mix: Double = 1 {
        didSet {
            mix = (0...1).clamp(mix)
            au[kDistortionParam_FinalMix] = mix * 100
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    open dynamic var isStarted = true

    // MARK: - Initialization

    /// Initialize the decimator node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - decimation: Decimation (Normalized Value) ranges from 0 to 1 (Default: 0.5)
    ///   - rounding: Rounding (Normalized Value) ranges from 0 to 1 (Default: 0)
    ///   - mix: Mix (Normalized Value) ranges from 0 to 1 (Default: 1)
    ///
    public init(
        _ input: AKNode?,
        decimation: Double = 0.5,
        rounding: Double = 0,
        mix: Double = 1) {

            self.decimation = decimation
            self.rounding = rounding
            self.mix = mix

            let effect = _Self.effect
            au = AUWrapper(effect)
            super.init(avAudioNode: effect, attach: true)

            input?.addConnectionPoint(self)

            // Since this is the Decimator, mix it to 100% and use the final mix as the mix parameter

            au[kDistortionParam_Decimation] = decimation * 100
            au[kDistortionParam_Rounding] = rounding * 100
            au[kDistortionParam_FinalMix] = mix * 100

            au[kDistortionParam_PolynomialMix] = 0
            au[kDistortionParam_RingModMix] = 0
            au[kDistortionParam_DelayMix] = 0
    }

    // MARK: - Control

    /// Function to start, play, or activate the node, all do the same thing
    open func start() {
        if isStopped {
            mix = lastKnownMix
            isStarted = true
        }
    }

    /// Function to stop or bypass the node, both are equivalent
    open func stop() {
        if isPlaying {
            lastKnownMix = mix
            mix = 0
            isStarted = false
        }
    }
    
    /// Disconnect the node
    override open func disconnect() {
        stop()
        disconnect(nodes: [self.avAudioNode])
    }
}
