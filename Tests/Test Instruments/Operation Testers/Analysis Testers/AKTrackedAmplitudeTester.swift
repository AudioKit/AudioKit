//
//  AKTrackedAmplitudeTester.swift
//  OSXAudioKit
//
//  Created by Aurelius Prochazka on 9/19/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Foundation

class AKTrackedAmplitudeTester : AKInstrument {
    
    override init() {
        super.init()
        
        let amplitude = AKPhasor(frequency: 0.5.ak, phase: 0)
        
        let growingLouderOscillator = AKOscillator(waveform: AKTable.standardSineWave(), frequency: 880.ak, amplitude: amplitude, phase: 0)
        
        let trackedAmplitude = AKTrackedAmplitude(growingLouderOscillator)
        
        let growingHigherOscillator = AKOscillator()
        growingHigherOscillator.frequency = trackedAmplitude * 880.ak
        
        output = AKAudioOutput(growingHigherOscillator)
    }
}
