//
//  FilterSection.swift
//  SwiftSynth
//
//  Created by Aurelius Prochazka on 1/11/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import AudioKit

class FilterSection: AKNode {
    var parameters: [Double] = [1000, 0.9, 0, 1000, 1, 1]
    
    var cutoffFrequency: Double = 1000 {
        didSet {
            parameters[0] = cutoffFrequency
            output.parameters = parameters
        }
    }
    
    var resonance: Double = 0.9 {
        didSet {
            parameters[1] = resonance
            output.parameters = parameters
        }
    }

    var mix: Double = 0 {
        didSet {
            parameters[2] = mix
            output.parameters = parameters
        }
    }
    
    var lfoAmplitude: Double = 1000 {
        didSet {
            parameters[3] = lfoAmplitude
            output.parameters = parameters
        }
    }

    var lfoRate: Double = 1 {
        didSet {
            parameters[4] = lfoRate
            output.parameters = parameters
        }
    }

    var lfoMix: Double = 1 {
        didSet {
            parameters[5] = lfoMix
            output.parameters = parameters
        }
    }

    private var output: AKOperationEffect
    
    init(_ input: AKNode) {
        
        let cutoff  = AKOperation.parameters(0)
        let rez     = AKOperation.parameters(1)
        let filtMix = AKOperation.parameters(2)
        let oscAmp  = AKOperation.parameters(3)
        let oscRate = AKOperation.parameters(4)
        let oscMix  = AKOperation.parameters(5)
        
        let phasor = AKOperation.phasor(frequency: oscRate) * oscAmp * oscMix
        let moog = AKOperation.input.moogLadderFilter(cutoffFrequency: max(phasor + cutoff, 0), resonance: rez)
        let mixed = mixer(AKOperation.input, moog, balance: filtMix)
        output = AKOperationEffect(input, operation: mixed)
        output.parameters = parameters
        
        super.init()
        self.avAudioNode = output.avAudioNode
        input.addConnectionPoint(self)
        
    }
}