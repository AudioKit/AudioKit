// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Accelerate

/// Type of analysis
public enum AnalysisMode {
    /// Root Mean Squared
    case rms
    /// Peak
    case peak
}

public func detectAmplitude(_ inputs: [Float]..., mode: AnalysisMode = .rms) -> Float {
    inputs.reduce(0.0) { partialResult, input in
        let length = input.count
        if mode == .rms {
            var rms: Float = 0
            vDSP_rmsqv(input, 1, &rms, UInt(length))
            return partialResult + rms / Float(inputs.count)
        } else {
            var peak: Float = 0
            var index: vDSP_Length = 0
            vDSP_maxvi(input, 1, &peak, &index, UInt(length))
            return partialResult + peak / Float(inputs.count)
        }
    }

}

public func detectAmplitudes(_ inputs: [[Float]], mode: AnalysisMode = .rms) -> [Float] {
    inputs.map { detectAmplitude($0) }
}

