//
//  morphingOscillator.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import Foundation

extension AKOperation {

    /// Morphing Oscillator 
    ///
    /// - Parameters:
    ///   - frequency: Frequency in cycles per second (Default: 440)
    ///   - amplitude: Amplitude of the output (Default: 1)
    ///   - index: Index of waveform 0.0 - 3.0 where 0 = sine, 1 = square, 2 = sawtooth, 3 = reversed sawtooth
    ///
    public static func morphingOscillator(
        frequency: AKParameter = 440,
        amplitude: AKParameter = 1,
        index: AKParameter = 0
        ) -> AKOperation {
        let sine     = "\"sine\"     4096  gen_sine \n"
        let square   = "\"square\"   4096 \"0 1 2047 1 2048 -1 4095 -1\" gen_line \n"
        let sawtooth = "\"sawtooth\" 4096 \"0 -1 4095 1\" gen_line \n"
        let revsaw   = "\"revsaw\"   4096 \"0 1 4095 -1\" gen_line \n"

        return AKOperation(module: "3 / 0 \"sine\" \"square\" \"sawtooth\" \"revsaw\" oscmorph4",
                           setup: "\(sine) \(square) \(sawtooth) \(revsaw)",
                           inputs: frequency, amplitude, index)
    }
}
