//
//  AKMixTester.swift
//  OSXAudioKit
//
//  Created by Aurelius Prochazka on 9/18/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Foundation

class AKMixTester : AKInstrument {
    
    override init() {
        super.init()
        
        let osc1 = AKOscillator()
        osc1.frequency = 300.ak
        
        let osc2 = AKOscillator()
        osc2.frequency = 500.ak
        
        let lfo = AKOscillator()
        lfo.frequency = 3.ak

        let mix = AKMix(input1: osc1, input2: osc2, balancePoint: (lfo + 1 ) / 2 )
        
        output = AKAudioOutput(mix)
    }
}
