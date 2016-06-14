//
//  sawtooth.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation

extension AKOperation {
    
    /// Simple sawtooth oscillator, not-band limited, can be used for LFO or wave,
    /// but sawtoothWave is probably better for audio.
    ///
    /// - returns: AKOperation
    /// - parameter frequency: In cycles per second, or Hz. (Default: 440, Minimum: 0.0, Maximum: 20000.0)
    /// - parameter amplitude: Output Amplitude. (Default: 0.5, Minimum: 0.0, Maximum: 1.0)
    ///
    public static func sawtooth(
        frequency: AKParameter = 440,
        amplitude: AKParameter = 0.5,
        phase: AKParameter = 0
        ) -> AKOperation {
            return AKOperation("\"sawtooth\" 4096 \"0 -1 4095 1\" gen_line (\(frequency) \(amplitude) \(phase) \"sawtooth\" osc)")
    }
    
    /// Simple reverse sawtooth oscillator, not-band limited, can be used for LFO or wave.
    ///
    /// - returns: AKOperation
    /// - parameter frequency: In cycles per second, or Hz. (Default: 440, Minimum: 0.0, Maximum: 20000.0)
    /// - parameter amplitude: Output Amplitude. (Default: 0.5, Minimum: 0.0, Maximum: 1.0)
    ///
    public static func reverseSawtooth(
        frequency: AKParameter = 440,
        amplitude: AKParameter = 0.5,
        phase: AKParameter = 0
        ) -> AKOperation {
            return AKOperation("\"sawtooth\" 4096 \"0 1 4095 -1\" gen_line (\(frequency) \(amplitude) \(phase) \"sawtooth\" osc)")
    }
}
