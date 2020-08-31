// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit

/// AudioKit Compressor based on Apple's DynamicsProcessor Audio Unit
///
public class AKCompressor: AKNode, AKToggleable, AUEffect {
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(appleEffect: kAudioUnitSubType_DynamicsProcessor)

    private var au: AUWrapper

    /// Threshold (dB) ranges from -40 to 20 (Default: -20)
    public var threshold: AUValue = -20 {
        didSet {
            threshold = (-40...20).clamp(threshold)
            au[kDynamicsProcessorParam_Threshold] = threshold
        }
    }

    /// Head Room (dB) ranges from 0.1 to 40.0 (Default: 5)
    public var headRoom: AUValue = 5 {
        didSet {
            headRoom = (0.1...40).clamp(headRoom)
            au[kDynamicsProcessorParam_HeadRoom] = headRoom
        }
    }

    /// Attack Duration (seconds) ranges from 0.0001 to 0.2 (Default: 0.001)
    public var attackDuration: AUValue = 0.001 {
        didSet {
            attackDuration = (0.000_1...0.2).clamp(attackDuration)
            au[kDynamicsProcessorParam_AttackTime] = attackDuration
        }
    }

    /// Release Duration (seconds) ranges from 0.01 to 3 (Default: 0.05)
    public var releaseDuration: AUValue = 0.05 {
        didSet {
            releaseDuration = (0.01...3).clamp(releaseDuration)
            au[kDynamicsProcessorParam_ReleaseTime] = releaseDuration
        }
    }

    /// Compression Amount (dB) read only
    public var compressionAmount: AUValue {
        return au[kDynamicsProcessorParam_CompressionAmount]
    }

    /// Input Amplitude (dB) read only
    public var inputAmplitude: AUValue {
        return au[kDynamicsProcessorParam_InputAmplitude]
    }

    /// Output Amplitude (dB) read only
    public var outputAmplitude: AUValue {
        return au[kDynamicsProcessorParam_OutputAmplitude]
    }

    /// Master Gain (dB) ranges from -40 to 40 (Default: 0)
    public var masterGain: AUValue = 0 {
        didSet {
            masterGain = (-40...40).clamp(masterGain)
            au[kDynamicsProcessorParam_MasterGain] = masterGain
        }
    }

    // Store the internal effect
    fileprivate var internalEffect: AVAudioUnitEffect

    /// Tells whether the node is processing (ie. started, playing, or active)
    public var isStarted = true

    /// Initialize the dynamics processor node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - threshold: Threshold (dB) ranges from -40 to 20 (Default: -20)
    ///   - headRoom: Head Room (dB) ranges from 0.1 to 40.0 (Default: 5)
    ///   - attackDuration: Attack Duration (secs) ranges from 0.0001 to 0.2 (Default: 0.001)
    ///   - releaseDuration: Release Duration (secs) ranges from 0.01 to 3 (Default: 0.05)
    ///   - masterGain: Master Gain (dB) ranges from -40 to 40 (Default: 0)
    ///
    public init(
        _ input: AKNode? = nil,
        threshold: AUValue = -20,
        headRoom: AUValue = 5,
        attackDuration: AUValue = 0.001,
        releaseDuration: AUValue = 0.05,
        masterGain: AUValue = 0) {

        self.threshold = threshold
        self.headRoom = headRoom
        self.attackDuration = attackDuration
        self.releaseDuration = releaseDuration
        self.masterGain = masterGain

        let effect = _Self.effect
        internalEffect = effect
        au = AUWrapper(effect)

        super.init(avAudioNode: effect)

        if let input = input {
            connections.append(input)
        }

        au[kDynamicsProcessorParam_Threshold] = threshold
        au[kDynamicsProcessorParam_HeadRoom] = headRoom
        au[kDynamicsProcessorParam_AttackTime] = attackDuration
        au[kDynamicsProcessorParam_ReleaseTime] = releaseDuration
        au[kDynamicsProcessorParam_MasterGain] = masterGain
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
