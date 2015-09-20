//
//  AKChorus.swift
//  SwiftOSXProofOfConcept
//
//  Created by Aurelius Prochazka on 9/17/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Foundation

/** Stereo Chorus effect
*/
@objc class AKChorus : AKInstrument {
    
    var rate = 0.5.ak
    var width = 0.2.ak
    var depth = 1.ak
    
    /** initalize */
    convenience init(input: AKParameter) {
        self.init()
        let lfoL = AKOscillator()
        lfoL.frequency = rate - width / 2
        lfoL.amplitude = depth
        
        let lfoR = AKOscillator()
        lfoR.frequency = rate - width / 2
        lfoR.amplitude = depth
        
        let transposedLFOL = (lfoL + 1) * 0.5 + 0.1
        let transposedLFOR = (lfoR + 1) * 0.5 + 0.1
        
        let vdelL = AKVariableDelay(input: input)
        vdelL.delayTime = 0.01 * transposedLFOL
        
        let vdelR = AKVariableDelay(input: input)
        vdelR.delayTime = 0.01 * transposedLFOR
        
        let stereo = AKParameter(left: vdelL, right: vdelR)
        output = AKAudioOutput(stereo)
    }
}
