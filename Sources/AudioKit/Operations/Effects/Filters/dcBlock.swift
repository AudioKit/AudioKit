// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

extension ComputedParameter {

    /// Implements the DC blocking filter Y[i] = X[i] - X[i-1] + (igain * Y[i-1])
    /// Based on work by Perry Cook.
    ///
    /// - parameter input: Input audio signal
    ///
    public func dcBlock() -> Operation {
        return Operation(module: "dcblock", inputs: toMono())
    }
}
