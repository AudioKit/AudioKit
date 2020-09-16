// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit

/// AudioKit version of Apple's Reverb2 Audio Unit
///
public class AKReverb2: AKNode, AKToggleable {

    fileprivate let cd = AudioComponentDescription(
        componentType: kAudioUnitType_Effect,
        componentSubType: kAudioUnitSubType_Reverb2,
        componentManufacturer: kAudioUnitManufacturer_Apple,
        componentFlags: 0,
        componentFlagsMask: 0)

    internal var internalEffect = AVAudioUnitEffect()
    internal var internalAU: AudioUnit?

    fileprivate var lastKnownMix: AUValue = 50

    /// Dry Wet Mix (CrossFade) ranges from 0 to 1 (Default: 0.5)
    public var dryWetMix: AUValue = 0.5 {
        didSet {
            if dryWetMix < 0 {
                dryWetMix = 0
            }
            if dryWetMix > 1 {
                dryWetMix = 1
            }
            if let audioUnit = internalAU {
                AudioUnitSetParameter(audioUnit,
                                      kReverb2Param_DryWetMix,
                                      kAudioUnitScope_Global, 0,
                                      dryWetMix * 100.0, 0)
            }
        }
    }

    /// Gain (Decibels) ranges from -20 to 20 (Default: 0)
    public var gain: AUValue = 0 {
        didSet {
            if gain < -20 {
                gain = -20
            }
            if gain > 20 {
                gain = 20
            }
            if let audioUnit = internalAU {
                AudioUnitSetParameter(audioUnit,
                                      kReverb2Param_Gain,
                                      kAudioUnitScope_Global, 0,
                                      gain, 0)
            }
        }
    }

    /// Min Delay Time (Secs) ranges from 0.0001 to 1.0 (Default: 0.008)
    public var minDelayTime: AUValue = 0.008 {
        didSet {
            if minDelayTime < 0.000_1 {
                minDelayTime = 0.000_1
            }
            if minDelayTime > 1.0 {
                minDelayTime = 1.0
            }
            if let audioUnit = internalAU {
                AudioUnitSetParameter(audioUnit,
                                      kReverb2Param_MinDelayTime,
                                      kAudioUnitScope_Global, 0,
                                      minDelayTime, 0)
            }
        }
    }

    /// Max Delay Time (Secs) ranges from 0.0001 to 1.0 (Default: 0.050)
    public var maxDelayTime: AUValue = 0.050 {
        didSet {
            if maxDelayTime < 0.000_1 {
                maxDelayTime = 0.000_1
            }
            if maxDelayTime > 1.0 {
                maxDelayTime = 1.0
            }
            if let audioUnit = internalAU {
                AudioUnitSetParameter(audioUnit,
                                      kReverb2Param_MaxDelayTime,
                                      kAudioUnitScope_Global, 0,
                                      maxDelayTime, 0)
            }
        }
    }

    /// Decay Time At0 Hz (Secs) ranges from 0.001 to 20.0 (Default: 1.0)
    public var decayTimeAt0Hz: AUValue = 1.0 {
        didSet {
            if decayTimeAt0Hz < 0.001 {
                decayTimeAt0Hz = 0.001
            }
            if decayTimeAt0Hz > 20.0 {
                decayTimeAt0Hz = 20.0
            }
            if let audioUnit = internalAU {
                AudioUnitSetParameter(audioUnit,
                                      kReverb2Param_DecayTimeAt0Hz,
                                      kAudioUnitScope_Global, 0,
                                      decayTimeAt0Hz, 0)
            }
        }
    }

    /// Decay Time At Nyquist (Secs) ranges from 0.001 to 20.0 (Default: 0.5)
    public var decayTimeAtNyquist: AUValue = 0.5 {
        didSet {
            if decayTimeAtNyquist < 0.001 {
                decayTimeAtNyquist = 0.001
            }
            if decayTimeAtNyquist > 20.0 {
                decayTimeAtNyquist = 20.0
            }
            if let audioUnit = internalAU {
                AudioUnitSetParameter(audioUnit,
                                      kReverb2Param_DecayTimeAtNyquist,
                                      kAudioUnitScope_Global, 0,
                                      decayTimeAtNyquist, 0)
            }
        }
    }

    /// Randomize Reflections (Integer) ranges from 1 to 1000 (Default: 1)
    public var randomizeReflections: AUValue = 1 {
        didSet {
            if randomizeReflections < 1 {
                randomizeReflections = 1
            }
            if randomizeReflections > 1_000 {
                randomizeReflections = 1_000
            }
            if let audioUnit = internalAU {
                AudioUnitSetParameter(audioUnit,
                                      kReverb2Param_RandomizeReflections,
                                      kAudioUnitScope_Global, 0,
                                      randomizeReflections, 0)
            }
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    public var isStarted = true

    /// Initialize the reverb2 node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - dryWetMix: Dry Wet Mix (CrossFade) ranges from 0 to 1 (Default: 0.5)
    ///   - gain: Gain (Decibels) ranges from -20 to 20 (Default: 0)
    ///   - minDelayTime: Min Delay Time (Secs) ranges from 0.0001 to 1.0 (Default: 0.008)
    ///   - maxDelayTime: Max Delay Time (Secs) ranges from 0.0001 to 1.0 (Default: 0.050)
    ///   - decayTimeAt0Hz: Decay Time At0 Hz (Secs) ranges from 0.001 to 20.0 (Default: 1.0)
    ///   - decayTimeAtNyquist: Decay Time At Nyquist (Secs) ranges from 0.001 to 20.0 (Default: 0.5)
    ///   - randomizeReflections: Randomize Reflections (Integer) ranges from 1 to 1000 (Default: 1)
    ///
    public init(
        _ input: AKNode,
        dryWetMix: AUValue = 0.5,
        gain: AUValue = 0,
        minDelayTime: AUValue = 0.008,
        maxDelayTime: AUValue = 0.050,
        decayTimeAt0Hz: AUValue = 1.0,
        decayTimeAtNyquist: AUValue = 0.5,
        randomizeReflections: AUValue = 1) {

        self.dryWetMix = dryWetMix
        self.gain = gain
        self.minDelayTime = minDelayTime
        self.maxDelayTime = maxDelayTime
        self.decayTimeAt0Hz = decayTimeAt0Hz
        self.decayTimeAtNyquist = decayTimeAtNyquist
        self.randomizeReflections = randomizeReflections

        internalEffect = AVAudioUnitEffect(audioComponentDescription: cd)

        super.init(avAudioNode: AVAudioNode())

        avAudioUnit = internalEffect
        internalAU = internalEffect.audioUnit

        if let audioUnit = internalAU {
            AudioUnitSetParameter(audioUnit,
                                  kReverb2Param_DryWetMix,
                                  kAudioUnitScope_Global,
                                  0,
                                  dryWetMix * 100.0,
                                  0)
            AudioUnitSetParameter(audioUnit,
                                  kReverb2Param_Gain,
                                  kAudioUnitScope_Global,
                                  0,
                                  gain,
                                  0)
            AudioUnitSetParameter(audioUnit,
                                  kReverb2Param_MinDelayTime,
                                  kAudioUnitScope_Global,
                                  0,
                                  minDelayTime,
                                  0)
            AudioUnitSetParameter(audioUnit,
                                  kReverb2Param_MaxDelayTime,
                                  kAudioUnitScope_Global,
                                  0,
                                  maxDelayTime,
                                  0)
            AudioUnitSetParameter(audioUnit,
                                  kReverb2Param_DecayTimeAt0Hz,
                                  kAudioUnitScope_Global,
                                  0,
                                  decayTimeAt0Hz,
                                  0)
            AudioUnitSetParameter(audioUnit,
                                  kReverb2Param_DecayTimeAtNyquist,
                                  kAudioUnitScope_Global,
                                  0,
                                  decayTimeAtNyquist,
                                  0)
            AudioUnitSetParameter(audioUnit,
                                  kReverb2Param_RandomizeReflections,
                                  kAudioUnitScope_Global,
                                  0,
                                  randomizeReflections,
                                  0)
        }
        connections.append(input)

    }

    // MARK: - Control

    /// Function to start, play, or activate the node, all do the same thing
    public func start() {
        if isStopped {
            dryWetMix = lastKnownMix
            isStarted = true
        }
    }

    /// Function to stop or bypass the node, both are equivalent
    public func stop() {
        if isPlaying {
            lastKnownMix = dryWetMix
            dryWetMix = 0
            isStarted = false
        }
    }

    // TODO This node is untested
}
