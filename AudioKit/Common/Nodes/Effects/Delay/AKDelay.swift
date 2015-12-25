//
//  AKDelay.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 10/4/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Foundation
import AVFoundation

/** AudioKit version of Apple's Delay Audio Unit */
public struct AKDelay: AKNode {
    let delayAU = AVAudioUnitDelay()
    
    /// Required property for AKNode
    public var avAudioNode: AVAudioNode
        
    /** Delay time in seconds (Default: 1) */
    public var time: NSTimeInterval = 1 {
        didSet {
            if time < 0 {
                time = 0
            }
            delayAU.delayTime = time
        }
    }
    
    /** Feedback as a percentage (Default: 50) */
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
    
    /** Low pass cut-off frequency in Hertz (Default: 15000) */
    public var lowPassCutoff: Double = 15000.00 {
        didSet {
            if lowPassCutoff < 0 {
                lowPassCutoff = 0
            }
            delayAU.lowPassCutoff = Float(lowPassCutoff)
        }
    }
    
    /** Dry/Wet Mix (Default 50) */
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
    
    /** Initialize the delay node */
    public init(
        _ input: AKNode,
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
            AKManager.sharedInstance.engine.connect(input.avAudioNode, to: self.avAudioNode, format: AKManager.format)
            
            delayAU.delayTime = self.time
            delayAU.feedback = Float(feedback)
            delayAU.lowPassCutoff = Float(lowPassCutoff)
            delayAU.wetDryMix = Float(dryWetMix)
    }
}
