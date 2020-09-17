// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

extension Operation {

    /// Produce a set of triggers spaced apart by time.
    ///
    /// - parameter period: Time between triggers (in seconds). Updates at the start of each trigger. (Default: 1.0)
    ///
    public static func periodicTrigger(period: OperationParameter = 1.0) -> Operation {
        return Operation(module: "dmetro", inputs: period)
    }
}
