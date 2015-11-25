// Parameters for AUNewTimePitch

// Global, rate, 0.03125 -> 32.0, 1.0
public var kNewTimePitchParam_Rate: AudioUnitParameterID { get }
// Global, Cents, -2400 -> 2400, 1.0
public var kNewTimePitchParam_Pitch: AudioUnitParameterID { get }
// Global, generic, 3.0 -> 32.0, 8.0
public var kNewTimePitchParam_Overlap: AudioUnitParameterID { get }
