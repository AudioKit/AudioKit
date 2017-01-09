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
open class AKHighShelfFilter: AKNode, AKToggleable, AUComponent {

    public static let ComponentDescription = AudioComponentDescription(appleEffect: kAudioUnitSubType_HighShelfFilter)

    private var au: AUWrapper
    private var mixer: AKMixer

    /// Cut Off Frequency (Hz) ranges from 10000 to 22050 (Default: 10000)
    open var cutoffFrequency: Double = 10000 {
        didSet {
            cutoffFrequency = (10000...22050).clamp(cutoffFrequency)
            au[kHighShelfParam_CutOffFrequency] = cutoffFrequency
        }
    }

    /// Gain (dB) ranges from -40 to 40 (Default: 0)
    open var gain: Double = 0 {
        didSet {
            gain = (-40...40).clamp(gain)
            au[kHighShelfParam_Gain] = gain
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

            let internalEffect = AVAudioUnitEffect(audioComponentDescription: _Self.ComponentDescription)

            au = AUWrapper(au: internalEffect)
            super.init()

            AudioKit.engine.attach(internalEffect)
            AudioKit.engine.connect((effectGain?.avAudioNode)!, to: internalEffect)
            AudioKit.engine.connect(internalEffect, to: mixer.avAudioNode)
            avAudioNode = mixer.avAudioNode

            au[kHighShelfParam_CutOffFrequency] = cutoffFrequency
            au[kHighShelfParam_Gain] = gain
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
