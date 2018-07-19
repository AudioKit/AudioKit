//
//  AKReverb.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

/// AudioKit version of Apple's Reverb Audio Unit
///
open class AKReverb: AKNode, AKToggleable, AKInput {
    fileprivate let reverbAU = AVAudioUnitReverb()

    fileprivate var lastKnownMix: Double = 0.5

    /// Dry/Wet Mix (Default 0.5)
    @objc open dynamic var dryWetMix: Double = 0.5 {
        didSet {
            dryWetMix = (0...1).clamp(dryWetMix)
            reverbAU.wetDryMix = Float(dryWetMix) * 100
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    @objc open dynamic var isStarted = true

    /// Initialize the reverb node
    ///
    /// - Parameters:
    ///   - input: AKNode to reverberate
    ///   - dryWetMix: Amount of processed signal (Default: 0.5, Range: 0 - 1)
    ///
    @objc public init(_ input: AKNode? = nil, dryWetMix: Double = 0.5) {
        self.dryWetMix = dryWetMix
        super.init()

        self.avAudioNode = reverbAU
        AudioKit.engine.attach(self.avAudioNode)
        input?.connect(to: self)

        reverbAU.wetDryMix = Float(dryWetMix) * 100.0
    }

    /// Load an Apple Factory Preset
    open func loadFactoryPreset(_ preset: AVAudioUnitReverbPreset) {
        reverbAU.loadFactoryPreset(preset)
    }

    /// Function to start, play, or activate the node, all do the same thing
    @objc open func start() {
        if isStopped {
            dryWetMix = lastKnownMix
            isStarted = true
        }
    }

    /// Function to stop or bypass the node, both are equivalent
    @objc open func stop() {
        if isPlaying {
            lastKnownMix = dryWetMix
            dryWetMix = 0
            isStarted = false
        }
    }
}
