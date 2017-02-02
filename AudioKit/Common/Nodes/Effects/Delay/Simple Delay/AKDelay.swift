//
//  AKDelay.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation
import AVFoundation

/// AudioKit version of Apple's Delay Audio Unit
///
open class AKDelay: AKNode, AKToggleable {
    private let delayAU = AVAudioUnitDelay()

    fileprivate var lastKnownMix: Double = 0.5

    /// Delay time in seconds (Default: 1)
    open var time: TimeInterval {
        get {
            return delayAU.delayTime
        }
        set {
            delayAU.delayTime = max(newValue, 0)
        }
    }

    /// Feedback (Normalized Value) ranges from 0 to 1 (Default: 0.5)
    open var feedback: Double {
        get {
            return Double(delayAU.feedback)
        }
        set {
            delayAU.feedback = Float((0...1).clamp(newValue)) * 100.0
        }
    }

    /// Low pass cut-off frequency in Hertz (Default: 15000)
    open var lowPassCutoff: Double {
        get {
            return Double(delayAU.lowPassCutoff)
        }
        set {
            delayAU.lowPassCutoff = Float(max(newValue, 0))
        }
    }

    /// Dry/Wet Mix (Normalized Value) ranges from 0 to 1 (Default: 0.5)
    open var wetDryMix: Double{
        get {
            return Double(delayAU.wetDryMix)
        }
        set {
            delayAU.wetDryMix = Float((0...1).clamp(newValue)) * 100.0
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    open var isStarted = true

    /// Initialize the delay node
    ///
    /// - Parameters:
    ///   - input: Input audio AKNode to process
    ///   - time: Delay time in seconds (Default: 1)
    ///   - feedback: Amount of feedback (Normalized Value) ranges from 0 to 1 (Default: 0.5)
    ///   - lowPassCutoff: Low-pass cutoff frequency in Hz (Default 15000)
    ///   - wetDryMix: Amount of unprocessed (dry) to delayed (wet) audio (Normalized Value) ranges from 0 to 1 (Default: 0.5)
    ///
    public init(
        _ input: AKNode,
        time: Double = 1,
        feedback: Double = 0.5,
        lowPassCutoff: Double = 15000,
        wetDryMix: Double = 0.5) {
            super.init(avAudioNode: delayAU, attach: true)
            input.addConnectionPoint(self)

            self.time = time
            self.feedback = feedback
            self.lowPassCutoff = lowPassCutoff
            self.wetDryMix = wetDryMix
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
