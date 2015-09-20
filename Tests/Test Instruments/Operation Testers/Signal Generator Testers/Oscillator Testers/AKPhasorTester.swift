//
//  AKPhasorTester.swift
//  OSXAudioKit
//
//  Created by Aurelius Prochazka on 9/19/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Foundation

class  AKPhasorTester : AKInstrument {
    
    override init() {
        super.init()
        
        let frequency = 2000 * AKPhasor(frequency: 1.ak, phase: 0)

        let oscillator = AKOscillator(waveform: AKTable.standardSineWave(), frequency: frequency, amplitude: 0.5.ak, phase: 0)
        
        output = AKAudioOutput(oscillator)
    }
}