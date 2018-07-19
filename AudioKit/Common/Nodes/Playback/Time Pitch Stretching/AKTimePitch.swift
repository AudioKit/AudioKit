//
//  AKTimePitch.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

/// AudioKit version of Apple's TimePitch Audio Unit
///
open class AKTimePitch: AKNode, AKToggleable, AKInput {

    fileprivate let timePitchAU = AVAudioUnitTimePitch()

    /// Rate (rate) ranges from 0.03125 to 32.0 (Default: 1.0)
    @objc open dynamic var rate: Double = 1.0 {
        didSet {
            rate = (0.031_25...32).clamp(rate)
            timePitchAU.rate = Float(rate)
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    @objc open dynamic var isStarted: Bool {
        return !timePitchAU.bypass
    }

    /// Pitch (Cents) ranges from -2400 to 2400 (Default: 0.0)
    @objc open dynamic var pitch: Double = 0.0 {
        didSet {
            pitch = (-2_400...2_400).clamp(pitch)
            timePitchAU.pitch = Float(pitch)
        }
    }

    /// Overlap (generic) ranges from 3.0 to 32.0 (Default: 8.0)
    @objc open dynamic var overlap: Double = 8.0 {
        didSet {
            overlap = (3...32).clamp(overlap)
            timePitchAU.overlap = Float(overlap)
        }
    }

    /// Initialize the time pitch node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - rate: Rate (rate) ranges from 0.03125 to 32.0 (Default: 1.0)
    ///   - pitch: Pitch (Cents) ranges from -2400 to 2400 (Default: 0.0)
    ///   - overlap: Overlap (generic) ranges from 3.0 to 32.0 (Default: 8.0)
    ///
    @objc public init(
        _ input: AKNode? = nil,
        rate: Double = 1.0,
        pitch: Double = 0.0,
        overlap: Double = 8.0) {

        self.rate = rate
        self.pitch = pitch
        self.overlap = overlap

        super.init()
        self.avAudioNode = timePitchAU
        AudioKit.engine.attach(self.avAudioNode)
        input?.connect(to: self)
    }

    /// Function to start, play, or activate the node, all do the same thing
    @objc open func start() {
        timePitchAU.bypass = false
    }

    /// Function to stop or bypass the node, both are equivalent
    @objc open func stop() {
        timePitchAU.bypass = true
    }
}
