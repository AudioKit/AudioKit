// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

extension AKComputedParameter {

    /// Alter the average frequency of signal
    ///
    /// - Parameter semitones: Amount of shift
    ///
    public func pitchShift(semitones: AKParameter = 0) -> AKOperation {
        return AKOperation(module: "1000 100 pshift", inputs: toMono(), semitones)
    }
}
