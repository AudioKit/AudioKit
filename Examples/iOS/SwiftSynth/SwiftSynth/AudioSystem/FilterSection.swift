//
//  FilterSection.swift
//  SwiftSynth
//
//  Created by Aurelius Prochazka on 1/11/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation
import AudioKit

struct FilterSection {
    
    var output: AKOperationEffect
    var parameters: [Double] = [1000, 0.9, 0.9, 1000, 1, 1] {
        didSet {
            output.parameters = parameters
        }
    }
    
    init(_ input: AKNode) {
        let cutoffFrequencyParameter = AKOperation.parameters(0)
        let resonanceParameter       = AKOperation.parameters(1)
        let filterMixParameter       = AKOperation.parameters(2)
        let lfoAmplitudeParameter    = AKOperation.parameters(3)
        let lfoRateParameter         = AKOperation.parameters(4)
        let lfoMixParameter          = AKOperation.parameters(5)
        
        let lfo = AKOperation.sawtooth(frequency: lfoRateParameter, amplitude: lfoAmplitudeParameter * lfoMixParameter)
        let moog = AKOperation.input.moogLadderFilter(cutoffFrequency: lfo + cutoffFrequencyParameter, resonance: resonanceParameter)
        let mixed = mix(AKOperation.input, moog, t: filterMixParameter)
        output = AKOperationEffect(input, operation: mixed)
        
        output.parameters = parameters
    }
}