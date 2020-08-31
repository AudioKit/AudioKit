// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit

/// AudioKit version of Apple's HighShelfFilter Audio Unit
///
public class AKHighShelfFilter: AKNode, AKToggleable, AUEffect {
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(appleEffect: kAudioUnitSubType_HighShelfFilter)

    private var au: AUWrapper

    /// Cut Off Frequency (Hz) ranges from 10000 to 22050 (Default: 10000)
    public var cutoffFrequency: AUValue = 10_000 {
        didSet {
            cutoffFrequency = (10_000...22_050).clamp(cutoffFrequency)
            au[kHighShelfParam_CutOffFrequency] = cutoffFrequency
        }
    }

    /// Gain (dB) ranges from -40 to 40 (Default: 0)
    public var gain: AUValue = 0 {
        didSet {
            gain = (-40...40).clamp(gain)
            au[kHighShelfParam_Gain] = gain
        }
    }

    // Store the internal effect
    fileprivate var internalEffect: AVAudioUnitEffect

    /// Tells whether the node is processing (ie. started, playing, or active)
    public var isStarted = true

    // MARK: - Initialization

    /// Initialize the high shelf filter node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - cutOffFrequency: Cut Off Frequency (Hz) ranges from 10000 to 22050 (Default: 10000)
    ///   - gain: Gain (dB) ranges from -40 to 40 (Default: 0)
    ///
    public init(
        _ input: AKNode? = nil,
        cutOffFrequency: AUValue = 10_000,
        gain: AUValue = 0) {

        self.cutoffFrequency = cutOffFrequency
        self.gain = gain

        let effect = _Self.effect
        internalEffect = effect
        au = AUWrapper(effect)

        super.init(avAudioNode: effect)

        if let input = input {
            connections.append(input)
        }

        au[kHighShelfParam_CutOffFrequency] = cutoffFrequency
        au[kHighShelfParam_Gain] = gain
    }

    // MARK: - Control

    /// Function to start, play, or activate the node, all do the same thing
    public func start() {
        internalEffect.bypass = false
    }

    /// Function to stop or bypass the node, both are equivalent
    public func stop() {
        internalEffect.bypass = true
    }
}
