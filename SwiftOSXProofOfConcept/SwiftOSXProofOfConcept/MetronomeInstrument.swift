//
//  MetronomeInstrument.swift
//  SwiftOSXProofOfConcept
//
//  Created by Aurelius Prochazka on 9/17/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Foundation


/** Testing instrument */
class MetronomeInstrument : AKInstrument {
    
    var playNote = AKTrigger()
    
    /** initalize */
    override init() {
        
        // Method 1: Full Initializer
        let oscillatingFrequency = AKOscillator(
            waveform: AKTable.standardSineWave(),
            frequency: akp(1),
            amplitude: akp(44),
            phase: 0.0
        )
        
        let simple = AKOscillator()
        simple.frequency = 440 + 2.0 * oscillatingFrequency
        
        let metro = AKMetronome()
        metro.frequency = oscillatingFrequency.frequency
        
        let env1trigger = AKTriggeredAHDEnvelope(trigger: playNote)
        let env1metro   = AKTriggeredAHDEnvelope(trigger: metro, attackDuration: 0.01.ak, holdDuration: 0.03.ak, releaseDuration: 0.02.ak)
        
        let env2metro = AKTriggeredAttackReleaseEnvelope(trigger: metro)
        
        super.init()
        
        output = AKAudioOutput(simple * env1metro)
    }
    
}