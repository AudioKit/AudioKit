// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

extension AKComputedParameter {

    /// Panner
    ///
    /// - parameter input: Input audio signal
    ///
    public func trackedAmplitude(_ trackedAmplitude: AKParameter = 0) -> AKOperation {
        return AKOperation(module: "rms", inputs: toMono())
    }
}
