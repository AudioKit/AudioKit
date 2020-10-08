// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

extension Operation {

    /// Trigger based linear AHD envelope generator
    ///
    /// - Parameters:
    ///   - trigger: A triggering operation such as a metronome
    ///   - attack: Attack duration, in seconds. (Default: 0.1)
    ///   - hold: Hold duration, in seconds. (Default: 0.3)
    ///   - release: Release duration, in seconds. (Default: 0.2)
    ///
    public func triggeredWithEnvelope(
        trigger: OperationParameter,
        attack: OperationParameter = 0.1,
        hold: OperationParameter = 0.3,
        release: OperationParameter = 0.2
        ) -> Operation {
        return Operation(module: "tenv *", inputs: self, trigger, attack, hold, release)
    }
}
