//
//  triangleWave.swift
//  AudioKit For iOS
//
//  Created by Aurelius Prochazka on 12/16/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Foundation

extension AKParameter {
    
    /** triangleWave: Triangle wave oscillator -
     - returns: AKParameter
     - Parameter frequency: Frequency in cycles per second (Default: 440)
     - Parameter amplitude: Amplitude of the output (Default: 1)
     */
    public static func triangleWave(
        frequency frequency: AKParameter = 440.ak,
        amplitude: AKParameter = 1.ak
        ) -> AKParameter {
            return AKParameter("\(frequency)\(amplitude)triangle")
    }
}

// Global Helper function

/** triangleWave: triangle wave oscillator -
- returns: AKParameter
- Parameter frequency: Frequency in cycles per second (Default: 440)
- Parameter amplitude: Amplitude of the output (Default: 1)
*/
public func triangleWave(
    frequency frequency: AKParameter = 440.ak,
    amplitude: AKParameter = 1.ak
    ) -> AKParameter {
        return AKParameter.triangleWave(frequency: frequency, amplitude: amplitude)
}
