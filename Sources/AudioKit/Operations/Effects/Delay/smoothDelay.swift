// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

extension AKComputedParameter {

    /// Smooth variable delay line without varispeed pitch.
    ///
    /// - Parameters:
    ///   - time: Delay time (in seconds) that can be changed during performance. This value must not exceed the
    ///           maximum delay time. (Default: 1.0, Minimum: 0.0, Maximum: 10.0)
    ///   - samples: Interpolation samples (Default: 1024)
    ///   - feedback: Feedback amount. Should be a value between 0-1. (Default: 0.0, Minimum: 0.0, Maximum: 1.0)
    ///   - maximumDelayTime: The maximum delay time, in seconds. (Default: 5.0, Minimum: 0.0, Maximum: 10.0)
    ///
    public func smoothDelay(
        time: AKParameter = 1.0,
        feedback: AKParameter = 0.0,
        samples: Int = 1_024,
        maximumDelayTime: Double = 5.0
        ) -> AKOperation {
        return AKOperation(module: "smoothdelay",
                           inputs: toMono(), feedback, time, maximumDelayTime, Double(samples))
    }
}
