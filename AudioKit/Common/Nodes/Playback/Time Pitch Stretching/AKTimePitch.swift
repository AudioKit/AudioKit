//
//  AKTimePitch.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2017 Aurelius Prochazka. All rights reserved.
//

import AVFoundation

/// AudioKit version of Apple's TimePitch Audio Unit
///
open class AKTimePitch: AKNode, AKToggleable {

    fileprivate let timePitchAU = AVAudioUnitTimePitch()

    /// Rate (rate) ranges from 0.03125 to 32.0 (Default: 1.0)
    open var rate: Double = 1.0 {
        didSet {
            rate = (0.031_25...32).clamp(rate)
            timePitchAU.rate = Float(rate)
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    open var isStarted: Bool {
        return pitch != 0.0 || rate != 1.0
    }

    /// Pitch (Cents) ranges from -2400 to 2400 (Default: 0.0)
    open var pitch: Double = 0.0 {
        didSet {
            pitch = (-2_400...2_400).clamp(pitch)
            timePitchAU.pitch = Float(pitch)
        }
    }

    /// Overlap (generic) ranges from 3.0 to 32.0 (Default: 8.0)
    open var overlap: Double = 8.0 {
        didSet {
            overlap = (3...32).clamp(overlap)
            timePitchAU.overlap = Float(overlap)
        }
    }

    fileprivate var lastKnownRate: Double = 1.0
    fileprivate var lastKnownPitch: Double = 0.0

    /// Initialize the time pitch node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - rate: Rate (rate) ranges from 0.03125 to 32.0 (Default: 1.0)
    ///   - pitch: Pitch (Cents) ranges from -2400 to 2400 (Default: 1.0)
    ///   - overlap: Overlap (generic) ranges from 3.0 to 32.0 (Default: 8.0)
    ///
    public init(
        _ input: AKNode,
        rate: Double = 1.0,
        pitch: Double = 0.0,
        overlap: Double = 8.0) {

        self.rate = rate
        self.pitch = pitch
        self.overlap = overlap

        lastKnownPitch = pitch
        lastKnownRate = rate

        super.init()
        self.avAudioNode = timePitchAU
        AudioKit.engine.attach(self.avAudioNode)
        input.addConnectionPoint(self)
    }

    /// Function to start, play, or activate the node, all do the same thing
    open func start() {
        rate = lastKnownRate
        pitch = lastKnownPitch
    }

    /// Function to stop or bypass the node, both are equivalent
    open func stop() {
        lastKnownPitch = pitch
        lastKnownRate = rate
        pitch = 0.0
        rate = 1.0
    }
}
