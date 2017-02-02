//
//  AKReverb.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation
import AVFoundation

/// AudioKit version of Apple's Reverb Audio Unit
///
open class AKReverb: AKNode, AKToggleable {
    fileprivate let reverbAU = AVAudioUnitReverb()

    fileprivate var lastKnownMix: Double = 0.5

    /// Dry/Wet Mix (Default 0.5)
    open var wetDryMix: Double = 0.5 {
        didSet {
            wetDryMix = (0...1).clamp(wetDryMix)
            reverbAU.wetDryMix = Float(wetDryMix) * 100
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    open var isStarted = true

    /// Initialize the reverb node
    ///
    /// - Parameters:
    ///   - input: AKNode to reverberate
    ///   - wetDryMix: Amount of processed signal (Default: 0.5, Minimum: 0, Maximum: 1)
    ///
    public init(_ input: AKNode, wetDryMix: Double = 0.5) {
        self.wetDryMix = wetDryMix
        super.init()

        self.avAudioNode = reverbAU
        AudioKit.engine.attach(self.avAudioNode)
        input.addConnectionPoint(self)

        reverbAU.wetDryMix = Float(wetDryMix) * 100.0
    }

    /// Load an Apple Factory Preset
    open func loadFactoryPreset(_ preset: AVAudioUnitReverbPreset) {
        reverbAU.loadFactoryPreset(preset)
    }

    /// Function to start, play, or activate the node, all do the same thing
    open func start() {
        if isStopped {
            wetDryMix = lastKnownMix
            isStarted = true
        }
    }

    /// Function to stop or bypass the node, both are equivalent
    open func stop() {
        if isPlaying {
            lastKnownMix = wetDryMix
            wetDryMix = 0
            isStarted = false
        }
    }
}
