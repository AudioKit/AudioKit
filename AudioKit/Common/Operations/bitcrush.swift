//
//  bitcrush.swift
//  AudioKit For iOS
//
//  Created by Aurelius Prochazka on 12/3/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Foundation

extension AKP {
    /** bitCrush: Bit Crusher - This will digitally degrade a signal.
     - returns: AKParameter
     - Parameter input: Input audio signal.
     - Parameter bitDepth: The bit depth of signal output. Typically in range (1-24). Non-integer values are OK. (Default: 8, Minimum: 1, Maximum: 24)
     - Parameter sampleRate: The sample rate of signal output. (Default: 10000, Minimum: 0.0, Maximum: 20000.0)
     */
    public static func bitCrush(
        input: AKParameter,
        bitDepth: AKParameter = 8.ak,
        sampleRate: AKParameter = 10000.ak
        ) -> AKParameter {
            return AKParameter("\(input) \(bitDepth) \(sampleRate)  bitcrush")
    }
}
