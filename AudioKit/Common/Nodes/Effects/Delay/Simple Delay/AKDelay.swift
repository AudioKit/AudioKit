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
/// - Parameters:
///   - input: Input audio AKNode to process
///   - time: Delay time in seconds, ranges from 0 to 2 (Default: 1)
///   - feedback: Amount of feedback (Normalized Value) ranges from 0 to 1 (Default: 0.5)
///   - lowPassCutoff: Low-pass cutoff frequency in Hz (Default 15000)
///   - dryWetMix: Amount of unprocessed (dry) to delayed (wet) audio (Normalized Value) ranges from 0 to 1 (Default: 0.5)
///
open class AKDelay: AKNode, AKToggleable {
    let delayAU = AVAudioUnitDelay()

    fileprivate var lastKnownMix: Double = 0.5

    /// Delay time in seconds (Default: 1)
    open var time: TimeInterval = 1 {
        didSet {
            if time < 0 {
                time = 0
            }
            delayAU.delayTime = time
        }
    }

    /// Feedback (Normalized Value) ranges from 0 to 1 (Default: 0.5)
    open var feedback: Double = 0.5 {
        didSet {
            if feedback < 0 {
                feedback = 0
            }
            if feedback > 1 {
                feedback = 1
            }
            delayAU.feedback = Float(feedback) * 100.0
        }
    }

    /// Low pass cut-off frequency in Hertz (Default: 15000)
    open var lowPassCutoff: Double = 15000.00 {
        didSet {
            if lowPassCutoff < 0 {
                lowPassCutoff = 0
            }
            delayAU.lowPassCutoff = Float(lowPassCutoff)
        }
    }

    /// Dry/Wet Mix (Normalized Value) ranges from 0 to 1 (Default: 0.5)
    open var dryWetMix: Double = 0.5 {
        didSet {
            internalSetDryWetMix(dryWetMix)
        }
    }

    internal func internalSetDryWetMix(_ value: Double) {
        var newValue = value
        if newValue < 0 {
            newValue = 0
        }
        if newValue > 1 {
            newValue = 1
        }
        delayAU.wetDryMix = Float(newValue) * 100.0
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
    ///   - dryWetMix: Amount of unprocessed (dry) to delayed (wet) audio (Normalized Value) ranges from 0 to 1 (Default: 0.5)
    ///
    public init(
        _ input: AKNode,
        time: Double = 1,
        feedback: Double = 0.5,
        lowPassCutoff: Double = 15000,
        dryWetMix: Double = 0.5) {

            self.time = TimeInterval(Double(time))
            self.feedback = feedback
            self.lowPassCutoff = lowPassCutoff
            self.dryWetMix = dryWetMix

            super.init()
            self.avAudioNode = delayAU
            AudioKit.engine.attach(self.avAudioNode)
            input.addConnectionPoint(self)


            delayAU.delayTime = self.time
            delayAU.feedback = Float(feedback) * 100.0
            delayAU.lowPassCutoff = Float(lowPassCutoff)
            internalSetDryWetMix(dryWetMix)
    }

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
