//
//  AKHighShelfFilter.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

import AVFoundation

/// AudioKit version of Apple's HighShelfFilter Audio Unit
///
/// - Parameters:
///   - input: Input node to process
///   - cutOffFrequency: Cut Off Frequency (Hz) ranges from 10000 to 22050 (Default: 10000)
///   - gain: Gain (dB) ranges from -40 to 40 (Default: 0)
///
public class AKHighShelfFilter: AKNode, AKToggleable {

    private let cd = AudioComponentDescription(
        componentType: kAudioUnitType_Effect,
        componentSubType: kAudioUnitSubType_HighShelfFilter,
        componentManufacturer: kAudioUnitManufacturer_Apple,
        componentFlags: 0,
        componentFlagsMask: 0)

    internal var internalEffect = AVAudioUnitEffect()
    internal var internalAU: AudioUnit = nil

    private var mixer: AKMixer

    /// Cut Off Frequency (Hz) ranges from 10000 to 22050 (Default: 10000)
    public var cutoffFrequency: Double = 10000 {
        didSet {
            if cutoffFrequency < 10000 {
                cutoffFrequency = 10000
            }
            if cutoffFrequency > 22050 {
                cutoffFrequency = 22050
            }
            AudioUnitSetParameter(
                internalAU,
                kHighShelfParam_CutOffFrequency,
                kAudioUnitScope_Global, 0,
                Float(cutoffFrequency), 0)
        }
    }

    /// Gain (dB) ranges from -40 to 40 (Default: 0)
    public var gain: Double = 0 {
        didSet {
            if gain < -40 {
                gain = -40
            }
            if gain > 40 {
                gain = 40
            }
            AudioUnitSetParameter(
                internalAU,
                kHighShelfParam_Gain,
                kAudioUnitScope_Global, 0,
                Float(gain), 0)
        }
    }

    /// Dry/Wet Mix (Default 100)
    public var dryWetMix: Double = 100 {
        didSet {
            if dryWetMix < 0 {
                dryWetMix = 0
            }
            if dryWetMix > 100 {
                dryWetMix = 100
            }
            inputGain?.volume = 1 - dryWetMix / 100
            effectGain?.volume = dryWetMix / 100
        }
    }

    private var lastKnownMix: Double = 100
    private var inputGain: AKMixer?
    private var effectGain: AKMixer?

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
        _ input: AKNode,
        cutOffFrequency: Double = 10000,
        gain: Double = 0) {

            self.cutoffFrequency = cutOffFrequency
            self.gain = gain

            inputGain = AKMixer(input)
            inputGain!.volume = 0
            mixer = AKMixer(inputGain!)

            effectGain = AKMixer(input)
            effectGain!.volume = 1

            internalEffect = AVAudioUnitEffect(audioComponentDescription: cd)
            super.init()

            AudioKit.engine.attachNode(internalEffect)
            internalAU = internalEffect.audioUnit
            AudioKit.engine.connect((effectGain?.avAudioNode)!, to: internalEffect, format: AudioKit.format)
            AudioKit.engine.connect(internalEffect, to: mixer.avAudioNode, format: AudioKit.format)
            avAudioNode = mixer.avAudioNode

            AudioUnitSetParameter(internalAU, kHighShelfParam_CutOffFrequency, kAudioUnitScope_Global, 0, Float(cutOffFrequency), 0)
            AudioUnitSetParameter(internalAU, kHighShelfParam_Gain, kAudioUnitScope_Global, 0, Float(gain), 0)
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
}
