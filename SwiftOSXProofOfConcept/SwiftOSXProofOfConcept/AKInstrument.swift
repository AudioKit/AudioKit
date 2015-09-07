//
//  AKInstrument.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 9/5/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

import Foundation

class AKInstrument {
    var operations = Array<AKParameter>([])
    
    var oscillatingFrequency: AKOscillator
    var fmOscillator: AKFMOscillator
    
    init() {
        oscillatingFrequency = AKOscillator(
            frequency: akp(2),
            amplitude: akp(440),
            phase: 0.0
        )
        
        fmOscillator = AKFMOscillator(
            baseFrequency: oscillatingFrequency,
            carrierMultiplier: akp(3),
            modulatingMultiplier: akp(5),
            modulationIndex: akp(11),
            amplitude: akp(0.1))
        operations.append(oscillatingFrequency)
        operations.append(fmOscillator)
    }

}