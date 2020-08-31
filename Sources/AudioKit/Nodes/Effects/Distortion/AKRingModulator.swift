// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit

/// AudioKit version of Apple's Ring Modulator from the Distortion Audio Unit
///
public class AKRingModulator: AKNode, AKToggleable, AUEffect {

    // MARK: - Properties

    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(appleEffect: kAudioUnitSubType_Distortion)
    private var au: AUWrapper
    private var lastKnownMix: AUValue = 1

    /// Frequency1 (Hertz) ranges from 0.5 to 8000 (Default: 100)
    public var frequency1: AUValue = 100 {
        didSet {
            frequency1 = (0.5...8_000).clamp(frequency1)
            au[kDistortionParam_RingModFreq1] = frequency1
        }
    }

    /// Frequency2 (Hertz) ranges from 0.5 to 8000 (Default: 100)
    public var frequency2: AUValue = 100 {
        didSet {
            frequency2 = (0.5...8_000).clamp(frequency2)
            au[kDistortionParam_RingModFreq2] = frequency2
        }
    }

    /// Ring Mod Balance (Normalized Value) ranges from 0 to 1 (Default: 0.5)
    public var balance: AUValue = 0.5 {
        didSet {
            balance = (0...1).clamp(balance)
            au[kDistortionParam_RingModBalance] = balance * 100
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

    /// Initialize the ring modulator node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - frequency1: Frequency1 (Hertz) ranges from 0.5 to 8000 (Default: 100)
    ///   - frequency2: Frequency2 (Hertz) ranges from 0.5 to 8000 (Default: 100)
    ///   - balance: Balance (Normalized Value) ranges from 0 to 1 (Default: 0.5)
    ///   - mix: Mix (Normalized Value) ranges from 0 to 1 (Default: 1)
    ///
    public init(
        _ input: AKNode? = nil,
        frequency1: AUValue = 100,
        frequency2: AUValue = 100,
        balance: AUValue = 0.5,
        mix: AUValue = 1) {

        self.frequency1 = frequency1
        self.frequency2 = frequency2
        self.balance = balance
        self.mix = mix

        let effect = _Self.effect
        au = AUWrapper(effect)

        super.init(avAudioUnit: effect)

        if let input = input {
            connections.append(input)
        }

        // Since this is the Ring Modulator, mix it to 100% and use the final mix as the mix parameter
        au[kDistortionParam_RingModMix] = 100
        au[kDistortionParam_RingModFreq1] = frequency1
        au[kDistortionParam_RingModFreq2] = frequency2
        au[kDistortionParam_RingModBalance] = balance * 100
        au[kDistortionParam_FinalMix] = mix * 100
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
