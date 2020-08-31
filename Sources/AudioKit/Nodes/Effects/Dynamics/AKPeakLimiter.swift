// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit

/// AudioKit version of Apple's PeakLimiter Audio Unit
///
public class AKPeakLimiter: AKNode, AKToggleable, AUEffect {
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(appleEffect: kAudioUnitSubType_PeakLimiter)

    private var au: AUWrapper

    /// Attack Duration (Secs) ranges from 0.001 to 0.03 (Default: 0.012)
    public var attackDuration: AUValue = 0.012 {
        didSet {
            attackDuration = (0.001...0.03).clamp(attackDuration)
            au[kLimiterParam_AttackTime] = attackDuration
        }
    }

    /// Decay Duration (Secs) ranges from 0.001 to 0.06 (Default: 0.024)
    public var decayDuration: AUValue = 0.024 {
        didSet {
            decayDuration = (0.001...0.06).clamp(decayDuration)
            au[kLimiterParam_DecayTime] = decayDuration
        }
    }

    /// Pre Gain (dB) ranges from -40 to 40 (Default: 0)
    public var preGain: AUValue = 0 {
        didSet {
            preGain = (-40...40).clamp(preGain)
            au[kLimiterParam_PreGain] = preGain
        }
    }

    // Store the internal effect
    fileprivate var internalEffect: AVAudioUnitEffect

    /// Tells whether the node is processing (ie. started, playing, or active)
    public var isStarted = true

    /// Initialize the peak limiter node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - attackDuration: Attack Duration (Secs) ranges from 0.001 to 0.03 (Default: 0.012)
    ///   - decayDuration: Decay Duration (Secs) ranges from 0.001 to 0.06 (Default: 0.024)
    ///   - preGain: Pre Gain (dB) ranges from -40 to 40 (Default: 0)
    ///
    public init(
        _ input: AKNode? = nil,
        attackDuration: AUValue = 0.012,
        decayDuration: AUValue = 0.024,
        preGain: AUValue = 0) {

        self.attackDuration = attackDuration
        self.decayDuration = decayDuration
        self.preGain = preGain

        let effect = _Self.effect
        internalEffect = effect
        au = AUWrapper(effect)

        super.init(avAudioNode: effect)

        if let input = input {
            connections.append(input)
        }

        au[kLimiterParam_AttackTime] = attackDuration
        au[kLimiterParam_DecayTime] = decayDuration
        au[kLimiterParam_PreGain] = preGain
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
