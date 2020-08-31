// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit

/// AudioKit version of Apple's LowShelfFilter Audio Unit
///
public class AKLowShelfFilter: AKNode, AKToggleable, AUEffect {
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(appleEffect: kAudioUnitSubType_LowShelfFilter)

    private var au: AUWrapper

    /// Cutoff Frequency (Hz) ranges from 10 to 200 (Default: 80)
    public var cutoffFrequency: AUValue = 80 {
        didSet {
            cutoffFrequency = (10...200).clamp(cutoffFrequency)
            au[kAULowShelfParam_CutoffFrequency] = cutoffFrequency
        }
    }

    /// Gain (dB) ranges from -40 to 40 (Default: 0)
    public var gain: AUValue = 0 {
        didSet {
            gain = (-40...40).clamp(gain)
            au[kAULowShelfParam_Gain] = gain
        }
    }

    // Store the internal effect
    fileprivate var internalEffect: AVAudioUnitEffect

    // MARK: - Initialization

    /// Tells whether the node is processing (ie. started, playing, or active)
    public var isStarted = true

    /// Initialize the low shelf filter node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - cutoffFrequency: Cutoff Frequency (Hz) ranges from 10 to 200 (Default: 80)
    ///   - gain: Gain (dB) ranges from -40 to 40 (Default: 0)
    ///
    public init(
        _ input: AKNode? = nil,
        cutoffFrequency: AUValue = 80,
        gain: AUValue = 0) {
        self.cutoffFrequency = cutoffFrequency
        self.gain = gain

        let effect = _Self.effect
        internalEffect = effect
        au = AUWrapper(effect)

        super.init(avAudioNode: effect)

        if let input = input {
            connections.append(input)
        }

        au[kAULowShelfParam_CutoffFrequency] = cutoffFrequency
        au[kAULowShelfParam_Gain] = gain
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
