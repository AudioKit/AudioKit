//
//  AKDelay.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 10/4/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Foundation
import AVFoundation

/// AudioKit version of Apple's Delay Audio Unit
public class AKDelay: AKNode, AKToggleable {
    let delayAU = AVAudioUnitDelay()
    
    /// Required property for AKNode
    public var avAudioNode: AVAudioNode
    /// Required property for AKNode containing all the node's connections
    public var connectionPoints = [AVAudioConnectionPoint]()
    
    private var lastKnownMix: Double = 50
    
    /// Delay time in seconds (Default: 1)
    public var time: NSTimeInterval = 1 {
        didSet {
            if time < 0 {
                time = 0
            }
            delayAU.delayTime = time
        }
    }
    
    /// Feedback as a percentage (Default: 50)
    public var feedback: Double = 50.0 {
        didSet {
            if feedback < 0 {
                feedback = 0
            }
            if feedback > 100 {
                feedback = 100
            }
            delayAU.feedback = Float(feedback)
        }
    }
    
    /// Low pass cut-off frequency in Hertz (Default: 15000)
    public var lowPassCutoff: Double = 15000.00 {
        didSet {
            if lowPassCutoff < 0 {
                lowPassCutoff = 0
            }
            delayAU.lowPassCutoff = Float(lowPassCutoff)
        }
    }
    
    /// Dry/Wet Mix (Default 50)
    public var dryWetMix: Double = 50.0 {
        didSet {
            if dryWetMix < 0 {
                dryWetMix = 0
            }
            if dryWetMix > 100 {
                dryWetMix = 100
            }
            delayAU.wetDryMix = Float(dryWetMix)
        }
    }
    
    /// Tells whether the node is processing (ie. started, playing, or active)
    public var isStarted = true
    
    /// Initialize the delay node 
    ///
    /// - parameter input: Input audio AKNode to process
    /// - parameter time: Delay time in seconds (Default: 1)
    /// - parameter feedback: Percentage amount of feedback (Default: 50)
    /// - parameter lowPassCutoff: Low-pass cutoff frequency in Hz (Default 15000)
    /// - parameter dryWetMix: Percentage of unprocessed (dry) to delayed (wet) audio (Default: 50)
    ///
    public init(
        var _ input: AKNode,
        time: Double = 1,
        feedback: Double = 50,
        lowPassCutoff: Double = 15000,
        dryWetMix: Double = 50) {

            self.time = NSTimeInterval(Double(time))
            self.feedback = feedback
            self.lowPassCutoff = lowPassCutoff
            self.dryWetMix = dryWetMix
            
            self.avAudioNode = delayAU
            AKManager.sharedInstance.engine.attachNode(self.avAudioNode)
            input.addConnectionPoint(self)
            
            delayAU.delayTime = self.time
            delayAU.feedback = Float(feedback)
            delayAU.lowPassCutoff = Float(lowPassCutoff)
            delayAU.wetDryMix = Float(dryWetMix)
    }
    
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
