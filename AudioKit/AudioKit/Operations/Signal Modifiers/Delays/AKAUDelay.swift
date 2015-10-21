//
//  AKAUDelay.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 10/4/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Foundation
import AVFoundation

/** AudioKit version of Apple's Delay Audio Unit */
public class AKAUDelay: AKOperation {
    private let delayAU = AVAudioUnitDelay()
    
    /** Delay time in seconds (Default: 1) */
    public var delayTime:NSTimeInterval = 1 {
        didSet {
            delayAU.delayTime = delayTime
        }
    }
    
    /** Feedback as a percentage (Default: 50) */
    public var feedback:Float = 50.0 {
        didSet {
            delayAU.feedback = feedback
        }
    }
    
    /** Low pass cut-off frequency in Hertz (Default: 15000) */
    public var lowPassCutoff:Float = 15000.00 {
        didSet {
            delayAU.lowPassCutoff = lowPassCutoff
        }
    }
    
    /** Wet/Dry Mix (Default 50) */
    public var wetDryMix:Float = 50.0 {
        didSet {
            delayAU.wetDryMix = wetDryMix
        }
    }
    
    /** Initialize the delay operation */
    public init(_ input: AKOperation) {
        super.init()
        output = delayAU
        AKManager.sharedInstance.engine.attachNode(output!)
        AKManager.sharedInstance.engine.connect(input.output!, to: output!, format: nil)
    }
    
}