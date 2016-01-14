//
//  FilterSection.swift
//  SwiftSynth
//
//  Created by Aurelius Prochazka on 1/11/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import AudioKit

class FilterSection: AKNode {
    var parameters: [Double] = [1000, 0.9, 0, 1000, 1, 1, 0, 0, 0, 0, 0]
    
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
    
    var selectedWaveform: Int = 0 {
        didSet {
            for i in 6...10 { parameters[i] = 0 }
            parameters[selectedWaveform + 6] = 1.0
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
        
        let sineMix     = AKOperation.parameters(6)
        let squareMix   = AKOperation.parameters(7)
        let triangleMix = AKOperation.parameters(8)
        let phasorMix   = AKOperation.parameters(9)
        let reverseMix  = AKOperation.parameters(10)
        
        let sine     = AKOperation.sineWave(frequency: oscRate).scale(minimum: 0, maximum: 1) * oscAmp * oscMix * sineMix
        let square   = AKOperation.square(frequency: oscRate).scale(minimum: 0, maximum: 1) * oscAmp * oscMix * squareMix
        let triangle = AKOperation.triangle(frequency: oscRate).scale(minimum: 0, maximum: 1) * oscAmp * oscMix * triangleMix
        let phasor   = AKOperation.phasor(frequency: oscRate) * oscAmp * oscMix * phasorMix
        let reverse  = (1 - AKOperation.phasor(frequency: oscRate)) * oscAmp * oscMix * reverseMix
        let lfo = sine + square + triangle + phasor + reverse
        
        let moog = AKOperation.input.moogLadderFilter(cutoffFrequency: max(lfo + cutoff, 0), resonance: rez)
        let mixed = mixer(AKOperation.input, moog, balance: filtMix)
        output = AKOperationEffect(input, operation: mixed)
        output.parameters = parameters
        
        super.init()
        self.avAudioNode = output.avAudioNode
        input.addConnectionPoint(self)
        
    }
}