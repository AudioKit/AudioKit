// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit

/// AudioKit version of Apple's LowPassFilter Audio Unit
///
public class AKLowPassFilter: AKNode, AKToggleable, AUEffect {
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(appleEffect: kAudioUnitSubType_LowPassFilter)

    private var au: AUWrapper

    /// Cutoff Frequency (Hz) ranges from 10 to 22050 (Default: 6900)
    public var cutoffFrequency: AUValue = 6_900 {
        didSet {
            cutoffFrequency = (10...22_050).clamp(cutoffFrequency)
            au[kLowPassParam_CutoffFrequency] = cutoffFrequency
        }
    }

    /// Resonance (dB) ranges from -20 to 40 (Default: 0)
    public var resonance: AUValue = 0 {
        didSet {
            resonance = (-20...40).clamp(resonance)
            au[kLowPassParam_Resonance] = resonance
        }
    }

    // Store the internal effect
    fileprivate var internalEffect: AVAudioUnitEffect

    /// Tells whether the node is processing (ie. started, playing, or active)
    public var isStarted = true

    // MARK: - Initialization

    /// Initialize the low pass filter node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - cutoffFrequency: Cutoff Frequency (Hz) ranges from 10 to 22050 (Default: 6900)
    ///   - resonance: Resonance (dB) ranges from -20 to 40 (Default: 0)
    ///
    public init(
        _ input: AKNode? = nil,
        cutoffFrequency: AUValue = 6_900,
        resonance: AUValue = 0) {

        self.cutoffFrequency = cutoffFrequency
        self.resonance = resonance

        let effect = _Self.effect
        internalEffect = effect
        au = AUWrapper(effect)

        super.init(avAudioNode: effect)

        if let input = input {
            connections.append(input)
        }

        au[kLowPassParam_Resonance] = resonance
        au[kLowPassParam_CutoffFrequency] = cutoffFrequency
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
