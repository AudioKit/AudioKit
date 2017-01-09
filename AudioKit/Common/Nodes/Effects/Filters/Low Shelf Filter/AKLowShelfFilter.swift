//
//  AKLowShelfFilter.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

import AVFoundation

/// AudioKit version of Apple's LowShelfFilter Audio Unit
///
open class AKLowShelfFilter: AKNode, AKToggleable, AUEffect {

    public static let ComponentDescription = AudioComponentDescription(appleEffect: kAudioUnitSubType_LowShelfFilter)

    private var au: AUWrapper
    private var mixer: AKMixer

    /// Cutoff Frequency (Hz) ranges from 10 to 200 (Default: 80)
    open var cutoffFrequency: Double = 80 {
        didSet {
            cutoffFrequency = (10...200).clamp(cutoffFrequency)
            au[kAULowShelfParam_CutoffFrequency] = cutoffFrequency
        }
    }

    /// Gain (dB) ranges from -40 to 40 (Default: 0)
    open var gain: Double = 0 {
        didSet {
            gain = (-40...40).clamp(gain)
            au[kAULowShelfParam_Gain] = gain
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

    // MARK: - Initialization

    /// Tells whether the node is processing (ie. started, playing, or active)
    open var isStarted = true

    /// Initialize the low shelf filter node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - cutoffFrequency: Cutoff Frequency (Hz) ranges from 10 to 200 (Default: 80)
    ///   - gain: Gain (dB) ranges from -40 to 40 (Default: 0)
    ///
    public init(
        _ input: AKNode,
        cutoffFrequency: Double = 80,
        gain: Double = 0) {

        self.cutoffFrequency = cutoffFrequency
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

        au[kAULowShelfParam_CutoffFrequency] = cutoffFrequency
        au[kAULowShelfParam_Gain] = gain
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
