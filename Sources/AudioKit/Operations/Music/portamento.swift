// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

extension Operation {

    /// Portamento-style control signal smoothing
    /// Useful for smoothing out low-resolution signals and applying glissando to
    /// filters.
    ///
    /// - Parameters:
    ///   - input: Input audio signal
    ///   - halfDuration: Duration which the curve will traverse half the distance towards the new value,
    ///                   then half as much again, etc., theoretically never reaching its asymptote. (Default: 0.02)
    ///
    public func portamento(halfDuration: OperationParameter = 0.02) -> Operation {
        return Operation(module: "port", inputs: self, halfDuration)
    }
}
