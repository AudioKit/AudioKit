//
//  FilterSection.swift
//  AnalogSynthX
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import AudioKit

class FilterSection: AKNode {
    var parameters: [Double] = [1_000, 0.9, 1_000, 1, 0]

    var cutoffFrequency: Double = 1_000 {
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

    var lfoAmplitude: Double = 1_000 {
        didSet {
            parameters[2] = lfoAmplitude
            output.parameters = parameters
        }
    }

    var lfoRate: Double = 1 {
        didSet {
            parameters[3] = lfoRate
            output.parameters = parameters
        }
    }

    var lfoIndex: Double = 0 {
        didSet {
            parameters[4] = lfoIndex
            output.parameters = parameters
        }
    }

    var output: AKOperationEffect

    init(_ input: AKNode) {

        output = AKOperationEffect(input) { input, parameters in

            let cutoff = parameters[0]
            let rez = parameters[1]
            let oscAmp = parameters[2]
            let oscRate = parameters[3]
            let oscIndex = parameters[4]

            let lfo = AKOperation.morphingOscillator(frequency: oscRate,
                                                     amplitude: oscAmp,
                                                     index: oscIndex)

            return input.moogLadderFilter(cutoffFrequency: max(lfo + cutoff, 0),
                                          resonance: rez)
        }
        output.parameters = parameters

        super.init()
        self.avAudioNode = output.avAudioNode
        input.addConnectionPoint(self)

    }
}
