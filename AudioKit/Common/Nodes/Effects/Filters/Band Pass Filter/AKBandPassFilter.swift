//
//  AKBandPassFilter.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

import AVFoundation

/// AudioKit version of Apple's BandPassFilter Audio Unit
///
/// - Parameters:
///   - input: Input node to process
///   - centerFrequency: Center Frequency (Hz) ranges from 20 to 22050 (Default: 5000)
///   - bandwidth: Bandwidth (Cents) ranges from 100 to 12000 (Default: 600)
///
open class AKBandPassFilter: AKNode, AKToggleable {

    fileprivate let cd = AudioComponentDescription(
        componentType: kAudioUnitType_Effect,
        componentSubType: kAudioUnitSubType_BandPassFilter,
        componentManufacturer: kAudioUnitManufacturer_Apple,
        componentFlags: 0,
        componentFlagsMask: 0)

    internal var internalEffect = AVAudioUnitEffect()
    internal var internalAU: AudioUnit? = nil

    fileprivate var mixer: AKMixer

    /// Center Frequency (Hz) ranges from 20 to 22050 (Default: 5000)
    open var centerFrequency: Double = 5000 {
        didSet {
            if centerFrequency < 20 {
                centerFrequency = 20
            }
            if centerFrequency > 22050 {
                centerFrequency = 22050
            }
            AudioUnitSetParameter(
                internalAU!,
                kBandpassParam_CenterFrequency,
                kAudioUnitScope_Global, 0,
                Float(centerFrequency), 0)
        }
    }

    /// Bandwidth (Cents) ranges from 100 to 12000 (Default: 600)
    open var bandwidth: Double = 600 {
        didSet {
            if bandwidth < 100 {
                bandwidth = 100
            }
            if bandwidth > 12000 {
                bandwidth = 12000
            }
            AudioUnitSetParameter(
                internalAU!,
                kBandpassParam_Bandwidth,
                kAudioUnitScope_Global, 0,
                Float(bandwidth), 0)
        }
    }

    /// Dry/Wet Mix (Default 100)
    open var dryWetMix: Double = 100 {
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

    fileprivate var lastKnownMix: Double = 100
    fileprivate var inputGain: AKMixer?
    fileprivate var effectGain: AKMixer?

    /// Tells whether the node is processing (ie. started, playing, or active)
    open var isStarted = true

    // MARK: - Initialization

    /// Initialize the band pass filter node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - centerFrequency: Center Frequency (Hz) ranges from 20 to 22050 (Default: 5000)
    ///   - bandwidth: Bandwidth (Cents) ranges from 100 to 12000 (Default: 600)
    ///
    public init(
        _ input: AKNode,
        centerFrequency: Double = 5000,
        bandwidth: Double = 600) {

            self.centerFrequency = centerFrequency
            self.bandwidth = bandwidth

            inputGain = AKMixer(input)
            inputGain!.volume = 0
            mixer = AKMixer(inputGain!)

            effectGain = AKMixer(input)
            effectGain!.volume = 1

            internalEffect = AVAudioUnitEffect(audioComponentDescription: cd)
            super.init()

            AudioKit.engine.attach(internalEffect)
            internalAU = internalEffect.audioUnit
            AudioKit.engine.connect((effectGain?.avAudioNode)!, to: internalEffect, format: AudioKit.format)
            AudioKit.engine.connect(internalEffect, to: mixer.avAudioNode, format: AudioKit.format)
            avAudioNode = mixer.avAudioNode

            AudioUnitSetParameter(internalAU!, kBandpassParam_CenterFrequency, kAudioUnitScope_Global, 0, Float(centerFrequency), 0)
            AudioUnitSetParameter(internalAU!, kBandpassParam_Bandwidth, kAudioUnitScope_Global, 0, Float(bandwidth), 0)
    }

    // MARK: - Control

    /// Function to start, play, or activate the node, all do the same thing
    open func start() {
        if isStopped {
            dryWetMix = lastKnownMix
            isStarted = true
        }
    }

    /// Function to stop or bypass the node, both are equivalent
    open func stop() {
        if isPlaying {
            lastKnownMix = dryWetMix
            dryWetMix = 0
            isStarted = false
        }
    }
}
