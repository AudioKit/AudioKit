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
open class AKBandPassFilter: AKNode, AKToggleable, AUComponent {
    public static let ComponentDescription = AudioComponentDescription(appleEffect: kAudioUnitSubType_BandPassFilter)

    private var internalEffect = AVAudioUnitEffect()
    private var au: AUWrapper

    fileprivate var mixer: AKMixer

    /// Center Frequency (Hz) ranges from 20 to 22050 (Default: 5000)
    open var centerFrequency: Double = 5000 {
        didSet {
            centerFrequency = (20...22050).clamp(centerFrequency)
            au[kBandpassParam_CenterFrequency] = centerFrequency
        }
    }

    /// Bandwidth (Cents) ranges from 100 to 12000 (Default: 600)
    open var bandwidth: Double = 600 {
        didSet {
            bandwidth = (100...12000).clamp(bandwidth)
            au[kBandpassParam_Bandwidth] = bandwidth
        }
    }

    /// Dry/Wet Mix (Default 100)
    open var dryWetMix: Double = 100 {
        didSet {
            dryWetMix = (0...100).clamp(dryWetMix)
            inputGain?.volume = 1 - dryWetMix / 100
            effectGain?.volume = dryWetMix / 100
        }
    }

    private var lastKnownMix: Double = 100
    private var inputGain: AKMixer?
    private var effectGain: AKMixer?

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

            internalEffect = AVAudioUnitEffect(audioComponentDescription: _Self.ComponentDescription)
            au = AUWrapper(au: internalEffect.audioUnit)

            super.init()
            avAudioNode = mixer.avAudioNode

            AudioKit.engine.attach(internalEffect)
            AudioKit.engine.connect((effectGain?.avAudioNode)!, to: internalEffect)
            AudioKit.engine.connect(internalEffect, to: mixer.avAudioNode)

            au[kBandpassParam_CenterFrequency] = centerFrequency
            au[kBandpassParam_Bandwidth] = bandwidth
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
