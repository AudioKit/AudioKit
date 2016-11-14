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
open class AKHighShelfFilter: AKNode, AKToggleable, AUComponent {

    static let ComponentDescription = AudioComponentDescription(appleEffect: kAudioUnitSubType_HighShelfFilter)

    internal var internalEffect = AVAudioUnitEffect()
    internal var internalAU: AudioUnit? = nil

    fileprivate var mixer: AKMixer

    /// Cut Off Frequency (Hz) ranges from 10000 to 22050 (Default: 10000)
    open var cutoffFrequency: Double = 10000 {
        didSet {
            cutoffFrequency = (10000...22050).clamp(cutoffFrequency)
            AudioUnitSetParameter(
                internalAU!,
                kHighShelfParam_CutOffFrequency,
                kAudioUnitScope_Global, 0,
                Float(cutoffFrequency), 0)
        }
    }

    /// Gain (dB) ranges from -40 to 40 (Default: 0)
    open var gain: Double = 0 {
        didSet {
            gain = (-40...40).clamp(gain)
            AudioUnitSetParameter(
                internalAU!,
                kHighShelfParam_Gain,
                kAudioUnitScope_Global, 0,
                Float(gain), 0)
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

    fileprivate var lastKnownMix: Double = 100
    fileprivate var inputGain: AKMixer?
    fileprivate var effectGain: AKMixer?

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

            internalEffect = AVAudioUnitEffect(audioComponentDescription: _Self.ComponentDescription)
            super.init()

            AudioKit.engine.attach(internalEffect)
            internalAU = internalEffect.audioUnit
            AudioKit.engine.connect((effectGain?.avAudioNode)!, to: internalEffect, format: AudioKit.format)
            AudioKit.engine.connect(internalEffect, to: mixer.avAudioNode, format: AudioKit.format)
            avAudioNode = mixer.avAudioNode

            AudioUnitSetParameter(internalAU!, kHighShelfParam_CutOffFrequency, kAudioUnitScope_Global, 0, Float(cutOffFrequency), 0)
            AudioUnitSetParameter(internalAU!, kHighShelfParam_Gain, kAudioUnitScope_Global, 0, Float(gain), 0)
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
