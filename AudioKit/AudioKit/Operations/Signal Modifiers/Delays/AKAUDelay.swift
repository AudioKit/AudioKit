//
//  AKAUDelay.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 10/4/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Foundation
import AVFoundation

public class AKAUDelay: AKOperation {
    let delayAU = AVAudioUnitDelay()
    public var delayTime:NSTimeInterval = 1 {
        didSet {
            delayAU.delayTime = delayTime
        }
    }
    public var feedback:Float = 50.0 {
        didSet {
            delayAU.feedback = feedback
        }
    }
    public var lowPassCutoff:Float = 15000.00 {
        didSet {
            delayAU.lowPassCutoff = lowPassCutoff
        }
    }
    public var wetDryMix:Float = 100.0 {
        didSet {
            delayAU.wetDryMix = wetDryMix
        }
    }
    public init(_ input: AKOperation) {
        super.init()
        output = delayAU
        AKManager.sharedInstance.engine.attachNode(output!)
        AKManager.sharedInstance.engine.connect(input.output!, to: output!, format: nil)
    }
    
}