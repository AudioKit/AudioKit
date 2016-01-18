//
//  morphingOscillator.swift
//  AudioKit For iOS
//
//  Created by Aurelius Prochazka on 1/17/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation

extension AKOperation {
    
    /// Morphing Oscillator (under development, subject to change)
    ///
    /// - returns: AKOperation
    /// - parameter frequency: Frequency in cycles per second (Default: 440)
    /// - parameter amplitude: Amplitude of the output (Default: 1)
    /// - parameter index: Index of waveform 0.0 - 3.0 where 0 = sine, 1 = square, 2 = triangle, 3 = sawtooth
    ///
    public static func morphingOscillator(
        frequency frequency: AKParameter = 440,
        amplitude: AKParameter = 1,
        index: AKParameter = 0
        ) -> AKOperation {
            let sine     = "(\"sine\" 4096  gen_sine)"
            let square   = "(\"square\"   4096 \"0 1 2047 1 2048 -1 4095 -1\" gen_line)"
            let triangle = "(\"triangle\" 4096 \"0 0 1023 1 3071 -1 4095 0\" gen_line)"
            let sawtooth = "(\"sawtooth\" 4096 \"0 -1 4095 1\" gen_line)"
            let oscmorph4 = "(\(frequency) \(amplitude) \(index) 3 / 0 \"sine\" \"square\" \"triangle\" \"sawtooth\" oscmorph4)"

            return AKOperation("(\(sine) \(square) \(triangle) \(sawtooth) \(oscmorph4))")
    }
}