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
public class AKDelay: AKOperation {
    private let delayAU = AVAudioUnitDelay()
    
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
    public var feedback: Float = 50.0 {
        didSet {
            if feedback < 0 {
                feedback = 0
            }
            if feedback > 100 {
                feedback = 100
            }
            delayAU.feedback = feedback
        }
    }
    
    /** Low pass cut-off frequency in Hertz (Default: 15000) */
    public var lowPassCutoff: Float = 15000.00 {
        didSet {
            if lowPassCutoff < 0 {
                lowPassCutoff = 0
            }
            delayAU.lowPassCutoff = lowPassCutoff
        }
    }
    
    /** Dry/Wet Mix (Default 50) */
    public var dryWetMix: Float = 50.0 {
        didSet {
            if dryWetMix < 0 {
                dryWetMix = 0
            }
            if dryWetMix > 100 {
                dryWetMix = 100
            }
            delayAU.wetDryMix = dryWetMix
        }
    }
    
    /** Initialize the delay operation */
    public init(
        _ input: AKOperation,
        time: Float = 1,
        feedback: Float = 50,
        lowPassCutoff: Float = 15000,
        dryWetMix: Float = 50) {
            
        self.time = NSTimeInterval(Double(time))
        self.feedback = feedback
        self.lowPassCutoff = lowPassCutoff
        self.dryWetMix = dryWetMix
        
        super.init()
        output = delayAU
        AKManager.sharedInstance.engine.attachNode(output!)
        AKManager.sharedInstance.engine.connect(input.output!, to: output!, format: nil)
    }
}
