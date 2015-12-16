//
//  sawtoothWave.swift
//  AudioKit For iOS
//
//  Created by Aurelius Prochazka on 12/16/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Foundation

extension AKParameter {
    
    /** sawtoothWave: Sawtooth wave oscillator -
     - returns: AKParameter
     - Parameter frequency: Frequency in cycles per second (Default: 440)
     - Parameter amplitude: Amplitude of the output (Default: 1)
     */
    public static func sawtoothWave(
        frequency frequency: AKParameter = 440.ak,
        amplitude: AKParameter = 1.ak
        ) -> AKParameter {
            return AKParameter("\(frequency)\(amplitude)saw")
    }
}

// Global Helper function

/** sawtoothWave: Sawtooth wave oscillator -
- returns: AKParameter
- Parameter frequency: Frequency in cycles per second (Default: 440)
- Parameter amplitude: Amplitude of the output (Default: 1)
*/
public func sawtoothWave(
    frequency frequency: AKParameter = 440.ak,
    amplitude: AKParameter = 1.ak
    ) -> AKParameter {
        return AKParameter.sawtoothWave(frequency: frequency, amplitude: amplitude)
}
