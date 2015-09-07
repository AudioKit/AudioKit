//
//  AKInstrument.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 9/5/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

import Foundation

class AKInstrument {
    var operations = Array<AKFMOscillator>([])
    
    var fmOscillatingControl: AKFMOscillator
    var fmOscillator: AKFMOscillator
    
    init() {
        fmOscillatingControl = AKFMOscillator(
            baseFrequency: akp(2),
            carrierMultiplier: akp(1),
            modulatingMultiplier: akp(1),
            modulationIndex: akp(1),
            amplitude: akp(440))
        
        fmOscillator = AKFMOscillator(
            baseFrequency: fmOscillatingControl,
            carrierMultiplier: akp(3),
            modulatingMultiplier: akp(5),
            modulationIndex: akp(11),
            amplitude: akp(0.1))
        operations.append(fmOscillatingControl)
        operations.append(fmOscillator)
    }

}