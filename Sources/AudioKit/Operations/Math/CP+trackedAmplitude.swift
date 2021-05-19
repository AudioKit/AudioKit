// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

extension ComputedParameter {

    /// Tracked amplitude
    ///
    /// - parameter input: Input audio signal
    ///
    public func trackedAmplitude(_ trackedAmplitude: OperationParameter = 0) -> Operation {
        return Operation(module: "rms", inputs: toMono())
    }
}
