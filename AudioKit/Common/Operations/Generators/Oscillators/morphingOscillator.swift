//
//  morphingOscillator.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation

extension AKOperation {

    /// Morphing Oscillator (under development, subject to change)
    ///
    /// - Parameters:
    ///   - frequency: Frequency in cycles per second (Default: 440)
    ///   - amplitude: Amplitude of the output (Default: 1)
    ///   - index: Index of waveform 0.0 - 3.0 where 0 = sine, 1 = square, 2 = sawtooth, 3 = reversed sawtooth
    ///
    public static func morphingOscillator(
        frequency frequency: AKParameter = 440,
        amplitude: AKParameter = 1,
        index: AKParameter = 0
        ) -> AKOperation {
            let sine     = "(\"sine\"     4096  gen_sine)"
            let square   = "(\"square\"   4096 \"0 1 2047 1 2048 -1 4095 -1\" gen_line)"
            let sawtooth = "(\"sawtooth\" 4096 \"0 -1 4095 1\" gen_line)"
            let revsaw   = "(\"revsaw\"   4096 \"0 1 4095 -1\" gen_line)"
            let oscmorph4 = "(\(frequency) \(amplitude) \(index) 3 / 0 \"sine\" \"square\" \"sawtooth\" \"revsaw\" oscmorph4)"

            return AKOperation("(\(sine) \(square) \(sawtooth) \(revsaw) \(oscmorph4))")
    }
}
