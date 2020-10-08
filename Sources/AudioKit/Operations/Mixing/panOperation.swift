// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

extension ComputedParameter {

    /// Panner
    ///
    /// - Parameters:
    ///   - input: Input audio signal
    ///   - pan: Panning. A value of -1 is hard left, and a value of 1 is hard right, and 0 is center.
    ///          (Default: 0, Minimum: -1, Maximum: 1)
    ///
    public func pan(_ pan: OperationParameter = 0) -> StereoOperation {
        return StereoOperation(module: "pan", inputs: toMono(), pan)
    }

    /// Stereo Panner
    ///
    /// - Parameters:
    ///   - input: Input stereo audio signal
    ///   - pan: Panning. A value of -1 is hard left, and a value of 1 is hard right, and 0 is center.
    ///          (Default: 0, Minimum: -1, Maximum: 1)
    ///
    public func stereoPan(_ pan: OperationParameter = 0) -> StereoOperation {
        return StereoOperation(module: "panst", inputs: toStereo(), pan)
    }
}
