// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

extension Operation {

    /// Gate based linear AHD envelope generator
    ///
    /// - Parameters:
    ///   - gate: 1 for on and 0 for off
    ///   - attack: Attack duration, in seconds. (Default: 0.1)
    ///   - hold: Hold duration, in seconds. (Default: 0.3)
    ///   - release: Release duration, in seconds. (Default: 0.2)
    ///
    public func gatedADSREnvelope(
        gate: OperationParameter,
        attack: OperationParameter = 0.1,
        decay: OperationParameter = 0.0,
        sustain: OperationParameter = 1,
        release: OperationParameter = 0.2
        ) -> Operation {
        return Operation(module: "adsr *", inputs: toMono(), gate, attack, decay, sustain, release)
    }
}
