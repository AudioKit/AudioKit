// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit

/// AudioKit version of Apple's Decimator from the Distortion Audio Unit
///
public class AKDecimator: AKNode, AKToggleable, AUEffect {
    // MARK: - Properties

    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(appleEffect: kAudioUnitSubType_Distortion)

    private var au: AUWrapper
    private var lastKnownMix: AUValue = 1

    /// Decimation (Normalized Value) ranges from 0 to 1 (Default: 0.5)
    public var decimation: AUValue = 0.5 {
        didSet {
            decimation = (0...1).clamp(decimation)
            au[kDistortionParam_Decimation] = decimation * 100
        }
    }

    /// Rounding (Normalized Value) ranges from 0 to 1 (Default: 0)
    public var rounding: AUValue = 0 {
        didSet {
            rounding = (0...1).clamp(rounding)
            au[kDistortionParam_Rounding] = rounding * 100
        }
    }

    /// Mix (Normalized Value) ranges from 0 to 1 (Default: 1)
    public var mix: AUValue = 1 {
        didSet {
            mix = (0...1).clamp(mix)
            au[kDistortionParam_FinalMix] = mix * 100
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    public var isStarted = true

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
        _ input: AKNode? = nil,
        decimation: AUValue = 0.5,
        rounding: AUValue = 0,
        mix: AUValue = 1) {

        self.decimation = decimation
        self.rounding = rounding
        self.mix = mix

        let effect = _Self.effect
        au = AUWrapper(effect)
        super.init(avAudioUnit: effect)

        if let input = input {
            connections.append(input)
        }

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
    public func start() {
        if isStopped {
            mix = lastKnownMix
            isStarted = true
        }
    }

    /// Function to stop or bypass the node, both are equivalent
    public func stop() {
        if isPlaying {
            lastKnownMix = mix
            mix = 0
            isStarted = false
        }
    }

}
