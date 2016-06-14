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
/// - parameter input: Input node to process
/// - parameter cutoffFrequency: Cutoff Frequency (Hz) ranges from 10 to 200 (Default: 80)
/// - parameter gain: Gain (dB) ranges from -40 to 40 (Default: 0)
///
public class AKLowShelfFilter: AKNode, AKToggleable {

    private let cd = AudioComponentDescription(
        componentType: kAudioUnitType_Effect,
        componentSubType: kAudioUnitSubType_LowShelfFilter,
        componentManufacturer: kAudioUnitManufacturer_Apple,
        componentFlags: 0,
        componentFlagsMask: 0)

    internal var internalEffect = AVAudioUnitEffect()
    internal var internalAU: AudioUnit? = nil

    private var mixer: AKMixer

    /// Cutoff Frequency (Hz) ranges from 10 to 200 (Default: 80)
    public var cutoffFrequency: Double = 80 {
        didSet {
            if cutoffFrequency < 10 {
                cutoffFrequency = 10
            }            
            if cutoffFrequency > 200 {
                cutoffFrequency = 200
            }
            AudioUnitSetParameter(
                internalAU!,
                kAULowShelfParam_CutoffFrequency,
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
                internalAU!,
                kAULowShelfParam_Gain,
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

    // MARK: - Initialization
    
    /// Tells whether the node is processing (ie. started, playing, or active)
    public var isStarted = true

    /// Initialize the low shelf filter node
    ///
    /// - parameter input: Input node to process
    /// - parameter cutoffFrequency: Cutoff Frequency (Hz) ranges from 10 to 200 (Default: 80)
    /// - parameter gain: Gain (dB) ranges from -40 to 40 (Default: 0)
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

            internalEffect = AVAudioUnitEffect(audioComponentDescription: cd)
            super.init()
            
            AudioKit.engine.attach(internalEffect)
            internalAU = internalEffect.audioUnit
            AudioKit.engine.connect((effectGain?.avAudioNode)!, to: internalEffect, format: AudioKit.format)
            AudioKit.engine.connect(internalEffect, to: mixer.avAudioNode, format: AudioKit.format)
            avAudioNode = mixer.avAudioNode

            AudioUnitSetParameter(internalAU!, kAULowShelfParam_CutoffFrequency, kAudioUnitScope_Global, 0, Float(cutoffFrequency), 0)
            AudioUnitSetParameter(internalAU!, kAULowShelfParam_Gain, kAudioUnitScope_Global, 0, Float(gain), 0)
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
