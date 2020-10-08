// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

extension ComputedParameter {

    /// Add a delay to an incoming signal with optional feedback.
    ///
    /// - Parameters:
    ///   - time: Delay time, in seconds. (Default: 1.0, Range: 0 - 10)
    ///   - feedback: Feedback amount. (Default: 0.0, Range: 0 - 1)
    ///
    public func delay(
        time: Double = 1.0,
        feedback: OperationParameter = 0.0
        ) -> Operation {
        return Operation(module: "delay",
                           inputs: toMono(), feedback, time)
    }
}
